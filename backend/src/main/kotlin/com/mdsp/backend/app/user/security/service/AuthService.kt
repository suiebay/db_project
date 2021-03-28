package com.mdsp.backend.app.user.security.service

import com.mdsp.backend.app.profile.model.Profile
import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.user.exception.PasswordResetLinkException
import com.mdsp.backend.app.user.exception.ResourceAlreadyInUseException
import com.mdsp.backend.app.user.exception.ResourceNotFoundException
import com.mdsp.backend.app.user.exception.TokenRefreshException
import com.mdsp.backend.app.user.model.PasswordResetToken
import com.mdsp.backend.app.user.model.payload.*
import com.mdsp.backend.app.user.model.token.EmailVerificationToken
import com.mdsp.backend.app.user.model.token.RefreshToken
import com.mdsp.backend.app.user.repository.RefreshTokenRepository
import com.mdsp.backend.app.user.security.jwt.JwtProvider
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.crypto.password.PasswordEncoder
import java.util.*
import org.springframework.stereotype.Component
import org.springframework.stereotype.Service

@Service
class AuthService {
    private val logger: Logger = LoggerFactory.getLogger(JwtProvider::class.java)

    @Autowired
    lateinit var authenticationManager: AuthenticationManager

    @Autowired
    lateinit var emailVerificationTokenService: EmailVerificationTokenService

    @Autowired
    lateinit var refreshTokenService: RefreshTokenService

    @Autowired
    lateinit var passwordResetTokenService: PasswordResetTokenService

    @Autowired
    lateinit var refreshTokenRepository: RefreshTokenRepository

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Autowired
    lateinit var tokenProvider: JwtProvider

    @Autowired
    lateinit var passwordEncoder: PasswordEncoder

    @Autowired
    lateinit var encoder: PasswordEncoder

    fun authenticateUser(loginRequest: User): Optional<Authentication> {
        return Optional.ofNullable(authenticationManager.authenticate(UsernamePasswordAuthenticationToken(loginRequest.getUsername(),
                loginRequest.getPassword())))
    }

    fun generateToken(username: String): String {
        return tokenProvider.generateAccessJwtToken(username)
    }

    fun createAndPersistRefreshToken(loginRequest: User): Optional<RefreshToken> {
        var currentUser = profileRepository.findByUsernameAndDeletedAtIsNull(loginRequest.getUsername()!!)

        var refreshToken: RefreshToken = refreshTokenService.createRefreshToken()
        refreshToken.setProfileId(currentUser.get().getId()!!)
        refreshToken = refreshTokenService.save(refreshToken)
        return Optional.ofNullable<RefreshToken?>(refreshToken)
    }

    fun updateAndPersistRefreshToken(username: String, expiredRefresh: UUID): Optional<RefreshToken> {
        var currentUser = profileRepository.findByUsernameAndDeletedAtIsNull(username)
        var refreshTokenCandidate = refreshTokenRepository.findByProfileIdAndToken(currentUser.get().getId()!!, expiredRefresh)
        if(refreshTokenCandidate.isPresent) { refreshTokenRepository.deleteById(refreshTokenCandidate.get().getId()!!) }

        var refreshToken: RefreshToken = refreshTokenService.createRefreshToken()
        refreshToken.setProfileId(currentUser.get().getId()!!)
        refreshToken.setFromUsedToken(expiredRefresh)
        refreshToken = refreshTokenService.save(refreshToken)
        return Optional.ofNullable<RefreshToken?>(refreshToken)
    }

    fun refreshJwtToken(tokenRefreshRequest: TokenRefreshRequest): Optional<String>{
        var requestRefreshToken: UUID = tokenRefreshRequest.getRefreshToken()!!
        var refreshToken = refreshTokenService.findByToken(requestRefreshToken)
        if(refreshToken.isEmpty) { return Optional.of("null") }

        refreshTokenService.verifyExpiration(refreshToken.get())
        refreshTokenService.increaseCount(refreshToken.get())

        var currentUser = profileRepository.findByIdAndDeletedAtIsNull(refreshToken.get().getProfileId()!!)
        if(currentUser.isEmpty) { return Optional.of("null") }
        var newToken = generateToken(currentUser.get().getUsername()!!)

        return Optional.of(newToken)
    }

    fun generatePasswordResetToken(passwordResetLinkRequest: PasswordResetLinkRequest): Optional<PasswordResetToken>{
        var email: String = passwordResetLinkRequest.getEmail()!!
        val profileCandidate = profileRepository.findByEmailAndDeletedAtIsNull(email)
        if(profileCandidate.isEmpty) { throw PasswordResetLinkException(email, "No matching user found for the given request") }

        var passwordResetToken: PasswordResetToken = passwordResetTokenService.createToken()
        passwordResetToken.setUser(profileCandidate.get().getId()!!)
        passwordResetTokenService.save(passwordResetToken)
        return Optional.of(passwordResetToken)
    }

    fun resetPassword(passwordResetRequest: PasswordResetRequest): Optional<UUID> {
        val token: String? = passwordResetRequest.getToken()
        val passwordResetToken: Optional<PasswordResetToken> = passwordResetTokenService.findByToken(UUID.fromString(token!!))
        if(passwordResetToken.isEmpty) { throw ResourceNotFoundException("Password Reset Token", "Token Id", token) }

        passwordResetTokenService.verifyExpiration(passwordResetToken.get())
        val encodedPassword: String = passwordEncoder.encode(passwordResetRequest.getPassword())

        val profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(passwordResetToken.get().getProfileId()!!)
        profileCandidate.get().setPassword(encodedPassword)
        profileCandidate.get().setIsBlocked(null)
        profileCandidate.get().setLoginAttempts(0)
        profileRepository.save(profileCandidate.get())
        return Optional.of(profileCandidate.get().getId()!!)
    }

    fun confirmEmailRegistration(emailToken: String): Optional<UUID> {
        val emailVerificationToken: Optional<EmailVerificationToken> = emailVerificationTokenService.findByToken(emailToken)
        if(emailVerificationToken.isEmpty) { throw ResourceNotFoundException("Token", "Email Verification", emailToken) }

        val registeredUser: UUID = emailVerificationToken.get().getProfileId()!!
        val profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(registeredUser)

        if(profileCandidate.get().getEmailVerified()!!){
            logger.info("User [$emailToken] already registered.")
            return Optional.of(registeredUser)
        }

        emailVerificationTokenService.verifyExpiration(emailVerificationToken.get())
        emailVerificationToken.get().setConfirmedStatus()
        emailVerificationTokenService.save(emailVerificationToken.get())

        profileCandidate.get().markVerificationConfirmed()
        profileRepository.save(profileCandidate.get())
        return Optional.of(registeredUser)
    }

    fun recreateRegistrationToken(existingToken: String): Optional<EmailVerificationToken> {
        var emailVerificationToken: Optional<EmailVerificationToken> = emailVerificationTokenService.findByToken(existingToken)
        if(emailVerificationToken.isEmpty) { throw ResourceNotFoundException("Token", "Existing email verification", existingToken) }

        var profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(emailVerificationToken.get().getProfileId()!!)

        if(profileCandidate.isPresent && profileCandidate.get().getEmailVerified() == true) {
            return Optional.empty()
        }
        return Optional.ofNullable(emailVerificationTokenService.updateExistingTokenWithNameAndExpiry(emailVerificationToken.get()))
    }

    fun registerUser(newRegistrationRequest: RegistrationRequest): Optional<Profile> {
        var newRegistrationRequestEmail = newRegistrationRequest.getEmail()
        var profileCandidate = profileRepository.findByEmailAndDeletedAtIsNull(newRegistrationRequestEmail!!)
        if(profileCandidate.isPresent) {
            logger.error("Email alreay exists: " + newRegistrationRequestEmail)
            throw ResourceAlreadyInUseException("Email", "Address", newRegistrationRequestEmail)
        }
        logger.info("Trying to register new user [$newRegistrationRequest]")
        val newUser = Profile()
        newUser.setEmail(newRegistrationRequest.getEmail())
        newUser.setPassword(encoder.encode(newRegistrationRequest.getPassword()))
        newUser.setUsername(newRegistrationRequest.getEmail())
        newUser.setIsActive(true)
        newUser.setEmailVerified(false)
        profileRepository.save(newUser)
        return Optional.ofNullable(newUser)
    }

}
