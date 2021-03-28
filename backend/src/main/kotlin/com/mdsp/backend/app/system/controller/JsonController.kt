package com.mdsp.backend.app.system.controller

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

@RestController
@RequestMapping("")
class JsonController() {

    val counter = AtomicLong()

    @Autowired
    lateinit var personRepository: IProfileRepository

    @Autowired
    lateinit var authenticationManager: AuthenticationManager

    @Autowired
    lateinit var jwtProvider: JwtProvider

    @GetMapping("/json")
    fun getJson(): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 1
        status.message = ""
        return ResponseEntity(status, HttpStatus.OK)
    }

    @GetMapping("/json/version")
    fun getJsonVersion(): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 1
        status.message = "1.0.0"
        return ResponseEntity(status, HttpStatus.OK)
    }

}
