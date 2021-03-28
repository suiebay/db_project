package com.mdsp.backend.app.user.controller

import com.mdsp.backend.app.profile.model.Profile
import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.system.model.Json
import com.mdsp.backend.app.user.model.LoginUser
import com.mdsp.backend.app.user.security.jwt.JwtProvider
import com.mdsp.backend.app.user.security.jwt.JwtResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.bind.annotation.*
import java.util.concurrent.atomic.AtomicLong
import java.util.stream.Collectors
import javax.validation.Valid

@CrossOrigin(origins = ["https://space.mdsp.kz", "https://community.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api")
class BackendController() {

    val counter = AtomicLong()

    @Autowired
    lateinit var personRepository: IProfileRepository

    @Autowired
    lateinit var authenticationManager: AuthenticationManager

    @Autowired
    lateinit var jwtProvider: JwtProvider

    @PostMapping("/account/islogging")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    fun getUserIsLoggingAndRole(@Valid @RequestBody roles: List<String>, authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = "Bad response!"
        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()

        if (
            user.getId() !== null
            && user.getEnabled()!!
            && user.getRoles() !== null
            && user.getRoles()!!.size > 0
        ) {
            var result = user.getRoles()!!.filter { p -> roles.any { ("role_" + it).toLowerCase() == p.name.toLowerCase() } }
            if (result.size > 0) {
                status.status = 1
                status.message = "Greate response!"
            }

        }
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/account/islogging-reads")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    fun getUserIsLoggingAndRoleReads(@Valid @RequestBody role: String, authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = "Bad response!"

        var roles: ArrayList<String> = arrayListOf()
        roles.add(role);

        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()

        if (
                user.getId() !== null
                && user.getEnabled()!!
                && user.getRoles() !== null
                && user.getRoles()!!.size > 0
        ) {
            var result = user.getRoles()!!.filter { p -> roles.any { ("role_" + it).toLowerCase() == p.name.toLowerCase() } }
            if (result.size > 0) {
                status.status = 1
                status.message = "Greate response!"
            }

        }
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/account/refreshtoken")
    @PreAuthorize("isAuthenticated()")
    fun refreshToken(authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = "Bad response!"
        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()
        if (
                user.getId() !== null
                && user.getEnabled()!!
                && user.getRoles() !== null
                && user.getRoles()!!.size > 0
        ) {

            var refresh: LoginUser = LoginUser(user.getUsername(), user.pwd())
            val authentication = authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken(refresh.username, refresh.password))
            SecurityContextHolder.getContext().setAuthentication(authentication)

            val AccessJwt: String = jwtProvider.generateAccessJwtToken(user.getUsername()!!)
            val RefreshJwt: String = jwtProvider.generateRefreshJwtToken(user.getUsername()!!)

            val authorities: List<GrantedAuthority> = user.getRoles()!!.stream().map({ role -> SimpleGrantedAuthority(role.name) }).collect(Collectors.toList<GrantedAuthority>())
            return ResponseEntity.ok(JwtResponse(AccessJwt, RefreshJwt))
        } else {
            return ResponseEntity(status, HttpStatus.OK)
        }
    }

    @GetMapping("/usercontent")
    @PreAuthorize("hasRole('STUDENT') or hasRole('ADMIN')")
    @ResponseBody
    fun getUserContent(authentication: Authentication): String {
        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()
        return "Hello " + user.getUsername() + " " + user.getEmail() + " " + user.getId() + "!"
    }

    @GetMapping("/user-image")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    fun getUserImage(authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""
        val user = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name)
        if (user.isPresent && user.get().getAvatar() != null) {
            status.status = 1
            status.message = user.get().getAvatar()!!
        }
        return ResponseEntity(status, HttpStatus.OK)
    }


    @GetMapping("/admincontent")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getAdminContent(): String {
        return "Admin's content"
    }

    @GetMapping("/user/role/super/admin")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    fun isAdmin(authentication: Authentication): ResponseEntity<*> {
        var roles: List<String> = arrayListOf("admin")
        var status = Json.Status()
        status.status = 0
        status.message = "Not access!"
        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()
        if (
                user.getId() !== null
                && user.getEnabled()!!
                && user.getRoles() !== null
                && user.getRoles()!!.size > 0
        ) {
            var result = user.getRoles()!!.filter { p -> roles.any { ("role_" + it).toLowerCase() == p.name.toLowerCase() } }
            if (result.size > 0) {
                status.status = 1
                status.message = "Have access!"
            }
        }
        return ResponseEntity(status, HttpStatus.OK)
    }

    @GetMapping("/user/role")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    fun getRoles(authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = "Have access!"
        val user: Profile = personRepository.findByUsernameAndDeletedAtIsNull(authentication.name).get()
        if (user !== null) {
            status.status = 1
            var res = ""
            for (item in user.getRoles()!!) {
                res += item.name + ","
            }
            status.value = res.dropLast(1)
            return ResponseEntity(status, HttpStatus.OK)
        }
        return ResponseEntity(status, HttpStatus.OK)

    }
}
