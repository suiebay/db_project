package com.mdsp.backend.app.user.controller

import com.mdsp.backend.app.mail.service.MailService
import com.mdsp.backend.app.profile.model.Profile
import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.system.model.Json
import com.mdsp.backend.app.user.event.OnGenerateResetLinkEvent
import com.mdsp.backend.app.user.event.OnRegenerateEmailVerificationEvent
import com.mdsp.backend.app.user.event.OnUserAccountChangeEvent
import com.mdsp.backend.app.user.event.OnUserRegistrationCompleteEvent
import com.mdsp.backend.app.user.exception.InvalidTokenRequestException
import com.mdsp.backend.app.user.exception.PasswordResetException
import com.mdsp.backend.app.user.exception.UserRegistrationException
import com.mdsp.backend.app.user.model.payload.*
import com.mdsp.backend.app.user.model.token.EmailVerificationToken
import com.mdsp.backend.app.user.model.token.RefreshToken
import com.mdsp.backend.app.user.repository.EmailVerificationTokenRepository
import com.mdsp.backend.app.user.repository.PasswordResetTokenRepository
import com.mdsp.backend.app.user.repository.RefreshTokenRepository
import com.mdsp.backend.app.user.security.jwt.JwtProvider
import com.mdsp.backend.app.user.security.service.AuthService
import com.mdsp.backend.app.user.security.service.ResponseMessage
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.ApplicationEventPublisher
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.*
import org.springframework.web.servlet.support.ServletUriComponentsBuilder
import org.springframework.web.util.UriComponentsBuilder
import java.sql.Timestamp
import java.util.*
import javax.validation.Valid

@RestController
@RequestMapping("/api/auth")
class AuthController() {
    private val logger = Logger.getLogger(AuthController::class.java)

    @Autowired
    lateinit var authenticationManager: AuthenticationManager

    @Autowired
    lateinit var userRepository: IProfileRepository

    @Autowired
    lateinit var jwtProvider: JwtProvider

    @Autowired
    lateinit var authService: AuthService

    @Autowired
    lateinit var tokenProvider: JwtProvider

    @Autowired
    lateinit var refreshTokenRepository: RefreshTokenRepository

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Autowired
    private val mailService: MailService = MailService()

    @Autowired
    lateinit var  applicationEventPublisher: ApplicationEventPublisher

    @Autowired
    lateinit var  passwordResetTokenRepository: PasswordResetTokenRepository

    @Autowired
    lateinit var  emailVerificationTokenRepository: EmailVerificationTokenRepository

    @Autowired
    lateinit var encoder: PasswordEncoder

    @Value("\${frontend.scheme}")
    var scheme: String = ""

    @Value("\${frontend.host}")
    var frontHost: String = ""


//    @PostMapping("/signin")
//    fun authenticateUser(@Valid @RequestBody loginRequest: LoginUser): ResponseEntity<*> {
//
//        val userCandidate: Optional <Profile> = userRepository.findByUsernameAndDeletedAtIsNull(loginRequest.username!!)
//
//        if (userCandidate.isPresent) {
//            val user: Profile = userCandidate.get()
//            val authentication = authenticationManager.authenticate(
//                    UsernamePasswordAuthenticationToken(loginRequest.username, loginRequest.password))
//            SecurityContextHolder.getContext().setAuthentication(authentication)
//
//            val AccessJwt: String = jwtProvider.generateAccessJwtToken(user.getUsername()!!)
//            val RefreshJwt: String = jwtProvider.generateRefreshJwtToken(user.getUsername()!!)
//
//            val authorities: List<GrantedAuthority> = user.getRoles()!!.stream().map({ role -> SimpleGrantedAuthority(role.name)}).collect(Collectors.toList<GrantedAuthority>())
//            //return ResponseEntity.ok(mailService.sendEmailVerification("test", "suiebayzh@gmail.com"))
//            return ResponseEntity.ok(JwtResponse(AccessJwt, RefreshJwt))
//        } else {
//            return ResponseEntity(ResponseMessage("User not found or password wrong!"),
//                    HttpStatus.BAD_REQUEST)
//        }
//    }

    @PostMapping("/signin")
    fun authenticateUserLogin(@Valid @RequestBody loginRequest: User): ResponseEntity<*> {
        val userCandidate: Optional<Profile> = profileRepository.findByUsernameAndDeletedAtIsNull(loginRequest.getUsername()!!)
        if(userCandidate.isEmpty || userCandidate.get().getEnabled() != true) { return ResponseEntity(ResponseMessage("User not found or password wrong!"), HttpStatus.BAD_REQUEST) }
        try {
            if(userCandidate.get().getIsBlocked() != null && userCandidate.get().getIsBlocked()!!.time + 1800000 - System.currentTimeMillis() > 0){
                throw RuntimeException()
            }
            val authentication: Optional<Authentication> = authService.authenticateUser(loginRequest)
            SecurityContextHolder.getContext().setAuthentication(authentication.get())

            userCandidate.get().setLoginAttempts(0)
            userCandidate.get().setIsBlocked(null)
            profileRepository.save(userCandidate.get())

            val refreshTokenOptional = authService.createAndPersistRefreshToken(loginRequest)
            if (refreshTokenOptional.isEmpty) {
                return ResponseEntity(ResponseMessage("Couldn't create refresh token for: ${loginRequest}"), HttpStatus.BAD_REQUEST)
            }
            val refreshToken = refreshTokenOptional.get().getToken()
            val jwtToken: String = authService.generateToken(authentication.get().name)

            return ResponseEntity.ok(JwtAuthenticationResponse(jwtToken, refreshToken, tokenProvider.getExpiryDuration()))
        } catch (e: Exception){
            if(userCandidate.get().getLoginAttempts() >= 5){
                if(userCandidate.get().getIsBlocked() == null) {
                    userCandidate.get().setIsBlocked(Timestamp(System.currentTimeMillis()))
                }
                val blockedTimeMs: Long = userCandidate.get().getIsBlocked()!!.time
                if(blockedTimeMs + 1800000 - System.currentTimeMillis() < 0){
                    userCandidate.get().setLoginAttempts(1)
                    userCandidate.get().setIsBlocked(null)
                    profileRepository.save(userCandidate.get())
                    return ResponseEntity("User not found or password wrong!", HttpStatus.BAD_REQUEST)
                }

                val leftMinutes: Long = ((blockedTimeMs + 1800000 - System.currentTimeMillis()) / 1000) / 60
                val leftSeconds: Long = ((blockedTimeMs + 1800000 - System.currentTimeMillis()) / 1000) % 60

                profileRepository.save(userCandidate.get())
                return ResponseEntity("Your account will unblocked after $leftMinutes minutes and $leftSeconds seconds!", HttpStatus.BAD_REQUEST)
            }
            userCandidate.get().incrementLoginAttempts()
            profileRepository.save(userCandidate.get())
            return ResponseEntity("User not found or password wrong!", HttpStatus.BAD_REQUEST)
        }
    }

    @PostMapping("/signin-auth")
    fun authenticateUserLoginSecret(@Valid @RequestBody loginRequest: User): ResponseEntity<*> {
        val userCandidate: Optional<Profile> = profileRepository.findByUsernameAndDeletedAtIsNull(loginRequest.getUsername()!!)
        if(userCandidate.isEmpty || userCandidate.get().getEnabled() != true) { return ResponseEntity(ResponseMessage("User not found or password wrong!"), HttpStatus.BAD_REQUEST) }
        try {
            if(userCandidate.get().getIsBlocked() != null && userCandidate.get().getIsBlocked()!!.time + 1800000 - System.currentTimeMillis() > 0){
                throw RuntimeException()
            }
            val authentication: Optional<Authentication> = authService.authenticateUser(loginRequest)
            SecurityContextHolder.getContext().setAuthentication(authentication.get())

            userCandidate.get().setLoginAttempts(0)
            userCandidate.get().setIsBlocked(null)
            profileRepository.save(userCandidate.get())

            val refreshTokenOptional = authService.createAndPersistRefreshToken(loginRequest)
            if (refreshTokenOptional.isEmpty) {
                return ResponseEntity(ResponseMessage("Couldn't create refresh token for: ${loginRequest}"), HttpStatus.BAD_REQUEST)
            }
            val refreshToken = refreshTokenOptional.get().getToken()
            val jwtToken: String = authService.generateToken(authentication.get().name)
            val jwtAuth = JwtAuthenticationSecretResponse(jwtToken, refreshToken, tokenProvider.getExpiryDuration())
            jwtAuth.setLanguage(userCandidate.get().getLanguage())
            return ResponseEntity.ok(jwtAuth)
        } catch (e: Exception){
            if(userCandidate.get().getLoginAttempts() >= 5){
                if(userCandidate.get().getIsBlocked() == null) {
                    userCandidate.get().setIsBlocked(Timestamp(System.currentTimeMillis()))
                }
                val blockedTimeMs: Long = userCandidate.get().getIsBlocked()!!.time
                if(blockedTimeMs + 1800000 - System.currentTimeMillis() < 0){
                    userCandidate.get().setLoginAttempts(1)
                    userCandidate.get().setIsBlocked(null)
                    profileRepository.save(userCandidate.get())
                    return ResponseEntity("User not found or password wrong!", HttpStatus.BAD_REQUEST)
                }

                val leftMinutes: Long = ((blockedTimeMs + 1800000 - System.currentTimeMillis()) / 1000) / 60
                val leftSeconds: Long = ((blockedTimeMs + 1800000 - System.currentTimeMillis()) / 1000) % 60

                profileRepository.save(userCandidate.get())
                return ResponseEntity("Your account will unblocked after $leftMinutes minutes and $leftSeconds seconds!", HttpStatus.BAD_REQUEST)
            }
            userCandidate.get().incrementLoginAttempts()
            profileRepository.save(userCandidate.get())
            return ResponseEntity("User not found or password wrong!", HttpStatus.BAD_REQUEST)
        }
    }

    @PostMapping("/refresh")
    fun refreshJwtToken(@Valid @RequestBody tokenRefreshRequest: TokenRefreshRequest): ResponseEntity<*>{
        var status = Json.Status()
        status.status = 0
        status.message = "Unexpected error during token refresh. Please logout and login again."

        val usedToken = refreshTokenRepository.findByFromUsedToken(tokenRefreshRequest.getRefreshToken()!!)
        if(usedToken.isPresent) {
            refreshTokenRepository.deleteAllByProfileId(usedToken.get().getProfileId()!!)
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        val refreshTokenCandidate = refreshTokenRepository.findByToken(tokenRefreshRequest.getRefreshToken()!!)
        if(refreshTokenCandidate.isEmpty){
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        val updatedToken = authService.refreshJwtToken(tokenRefreshRequest)
        if(updatedToken.get().equals("null")){
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        val profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(refreshTokenCandidate.get().getProfileId()!!)
        if(profileCandidate.isEmpty) {
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        val refreshTokenOptional = authService.updateAndPersistRefreshToken(profileCandidate.get().getUsername()!!, refreshTokenCandidate.get().getToken())
        val refreshToken = refreshTokenOptional.get().getToken()

        return ResponseEntity.ok(JwtAuthenticationResponse(updatedToken.get(), refreshToken, tokenProvider.getExpiryDuration()))
    }

    @DeleteMapping("/deleterefresh")
    //@PreAuthorize("isAuthenticated()")
    fun deleteRefresh(@Valid @RequestBody refreshToken: RefreshToken): ResponseEntity<*>{
        refreshTokenRepository.deleteByToken(refreshToken.getToken())
        return ResponseEntity.ok("Deleted!")
    }

    @PostMapping("/password/resetlink")
    fun resetLink(@Valid @RequestBody passwordResetLinkRequest: PasswordResetLinkRequest): ResponseEntity<*>{
        var status = Json.Status()
        status.status = 0
        status.message = ""
        val profileCandidate = profileRepository.findByEmailAndDeletedAtIsNull(passwordResetLinkRequest.getEmail()!!)
        if(profileCandidate.isEmpty) { return ResponseEntity("Email does not exist!", HttpStatus.BAD_REQUEST)}
        val existedLink = passwordResetTokenRepository.findByProfileId(profileCandidate.get().getId()!!)
        if(existedLink.isPresent) {
            var leftTimeMs = System.currentTimeMillis() - existedLink.get().getCreatedAt()!!.time
            if (leftTimeMs < 60000) {
                status.message = "You already send reset link for your email, try after ${leftTimeMs/1000} seconds please!"
                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
            }
        }
        passwordResetTokenRepository.deleteAllByProfileId(profileCandidate.get().getId()!!)
        val passwordResetToken = authService.generatePasswordResetToken(passwordResetLinkRequest)

        val urlBuilder: UriComponentsBuilder = ServletUriComponentsBuilder.newInstance().scheme(this.scheme)
                .host(this.frontHost).pathSegment("#", "public", "reset-password")
        //println(urlBuilder.toUriString())
        val generateResetLinkMailEvent = OnGenerateResetLinkEvent(passwordResetToken.get(), urlBuilder)
//      com/mdsp/backend/app/user/event/listener/OnGenerateResetLinkEventListener.kt - query token
        applicationEventPublisher.publishEvent(generateResetLinkMailEvent)
        status.message = "Password reset link sent successfully"
        status.status = 1
        return ResponseEntity.ok(status)
    }

    @PostMapping("/password/reset")
    fun resetPassword(@Valid @RequestBody passwordResetRequest: PasswordResetRequest): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""
        val changeProfile = authService.resetPassword(passwordResetRequest)
        if(changeProfile.isEmpty) { throw PasswordResetException(passwordResetRequest.getToken(), "Error in resetting password") }

        val onPasswordChangeEvent = OnUserAccountChangeEvent(changeProfile.get(), "Reset Password", "Changed Successfully")
        applicationEventPublisher.publishEvent(onPasswordChangeEvent)

        val pwdResetTokens = passwordResetTokenRepository.deleteAllByProfileId(changeProfile.get())
        status.status = 1
        status.message = "Password changed successfully"
        return ResponseEntity.ok(status)
    }

    @PostMapping("/password/change")
    @PreAuthorize("isAuthenticated()")
    fun changePassword(@Valid @RequestBody passwordChangeRequest: PasswordChangeRequest, authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        var profileCandidate = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name!!)
        if(profileCandidate.isEmpty) {
            status.message = "User not found!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        if (!encoder.matches(passwordChangeRequest.getPassword(), profileCandidate.get().pwd())) {
            status.message = "Current is not true"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        println(passwordChangeRequest.getConfirmPassword())
        println(passwordChangeRequest.getNewPassword())
        if (passwordChangeRequest.getConfirmPassword() != passwordChangeRequest.getNewPassword())  {
            status.message = "Passwords are not same"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        profileCandidate.get().setPassword(encoder.encode(passwordChangeRequest.getNewPassword()))
        userRepository.save(profileCandidate.get())

        status.status = 1
        status.message = "Password changed successfully"
        return ResponseEntity.ok(status)
    }

    @PostMapping("/logout")
    fun logoutUser(authentication: Authentication, refreshToken: RefreshToken): ResponseEntity<*> {
        val profileCandidate = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name!!)
        if(profileCandidate.isEmpty) { return ResponseEntity("User does not exist", HttpStatus.BAD_REQUEST) }

        val refreshTokenCandidate = refreshTokenRepository
                .findByProfileIdAndToken(profileCandidate.get().getId()!!, refreshToken.getToken())

        if(refreshTokenCandidate.isEmpty) { return ResponseEntity("Refresh does not exist", HttpStatus.BAD_REQUEST)  }

        refreshTokenRepository.deleteById(refreshTokenCandidate.get().getId()!!)

        return ResponseEntity("Log out successful", HttpStatus.OK)
    }

    @PostMapping("/register")
    fun registerUser(@Valid @RequestBody registrationRequest: RegistrationRequest): ResponseEntity<*> {
        var user = authService.registerUser(registrationRequest)
        if(user.isEmpty) { throw UserRegistrationException(registrationRequest.getEmail()!!, "Missing user object in database") }

        var urlBuilder: UriComponentsBuilder = ServletUriComponentsBuilder.fromCurrentContextPath().path("/api/auth/registrationconfirmation")
        var onUserRegistrationCompleteEvent = OnUserRegistrationCompleteEvent(user.get(), urlBuilder)
        applicationEventPublisher.publishEvent(onUserRegistrationCompleteEvent)
        logger.info("Registered User returned [API[: $user")
        return ResponseEntity.ok("User registered successfully. Check your email for verification")
    }

    @GetMapping("/registrationconfirmation")
    fun confirmRegistration(@RequestParam("token") token: String): ResponseEntity<*> {
        val user = authService.confirmEmailRegistration(token)
        if(user.isPresent)
            return ResponseEntity("User verified successfully", HttpStatus.OK)
        else
            throw InvalidTokenRequestException("Email Verification Token", token, "Failed to confirm. Please generate a new email verification request")
    }

    @GetMapping("/resendregistrationtoken")
    fun resendRegistrationToken(@RequestParam("token") existingToken: String): ResponseEntity<*>{
        val existedLink = emailVerificationTokenRepository.findByToken(existingToken)
        if(existedLink.isPresent) {
            var leftTimeMs = ((Date.from(existedLink.get().getExpiryDate()).time - 60 * 59 * 1000) - System.currentTimeMillis())
            if (leftTimeMs in 0..60000) {
                return ResponseEntity("You already send verification link for your email, try after ${leftTimeMs / 1000} seconds please!", HttpStatus.BAD_REQUEST)
            }
        }

        var newEmailToken: Optional<EmailVerificationToken> = authService.recreateRegistrationToken(existingToken)
        if(newEmailToken.isEmpty) { throw InvalidTokenRequestException("Email Verification Token", existingToken, "User is already registered. No need to re-generate token") }

        try {
            var regisredUserId = newEmailToken.get().getProfileId()
            val urlBuilder: UriComponentsBuilder = ServletUriComponentsBuilder.fromCurrentContextPath().path("/api/auth/registrationconfirmation")
            var regenerateEmailVerificationEvent: OnRegenerateEmailVerificationEvent = OnRegenerateEmailVerificationEvent(regisredUserId!!, urlBuilder, newEmailToken.get())
            applicationEventPublisher.publishEvent(regenerateEmailVerificationEvent)
            return ResponseEntity.ok("Email verification resent successfully")
        } catch (e: Exception) {
            throw InvalidTokenRequestException("Email Verification Token", existingToken, "No user associated with this request. Re-verification denied")
        }
    }

//    @PostMapping("/signup")
//    fun registerUser(@Valid @RequestBody newUser: NewUser): ResponseEntity<*> {
//
//        val userCandidate: Optional <Profile> = userRepository.findByUsernameOrEmailAndDeletedAtIsNull(newUser.username!!, newUser.email!!)
//
//        if (!userCandidate.isPresent) {
//            if (usernameExists(newUser.username!!)) {
//                return ResponseEntity(ResponseMessage("Username is already taken!"),
//                        HttpStatus.BAD_REQUEST)
//            } else if (emailExists(newUser.email!!)) {
//                return ResponseEntity(ResponseMessage("Email is already in use!"),
//                        HttpStatus.BAD_REQUEST)
//            }
//
//            // Creating user's account
//            val user = Profile(
//                    null,
//                    newUser.username!!,
//                    newUser.email!!,
//                    encoder.encode(newUser.password),
//                    true
//            )
//            user!!.roles = Arrays.asList(roleRepository.findByName("ROLE_STUDENT"))
//
//            userRepository.save(user)
//
//            return ResponseEntity(ResponseMessage("User registered successfully!"), HttpStatus.OK)
//        } else {
//            return ResponseEntity(ResponseMessage("User already exists!"),
//                    HttpStatus.BAD_REQUEST)
//        }
//    }
//
//    private fun emailExists(email: String): Boolean {
//        return userRepository.findByEmailAndDeletedAtIsNull(email).isPresent
//    }
//
//    private fun usernameExists(username: String): Boolean {
//        return userRepository.findByUsernameAndDeletedAtIsNull(username).isPresent
//    }

}
