package com.mdsp.backend.app.profile.controller

import com.mdsp.backend.app.profile.model.*
import com.mdsp.backend.app.profile.repository.*
import com.mdsp.backend.app.user.repository.RoleRepository
import com.mdsp.backend.app.user.repository.UsersRoleRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.*
import kotlin.collections.ArrayList


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 1800)
@RestController
@RequestMapping("/api/v2/profiles")
class ProfileV2Controller {

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Autowired
    lateinit var usersRoleRepository: UsersRoleRepository

    @Autowired
    lateinit var encoder: PasswordEncoder

    @Autowired
    lateinit var roleRepository: RoleRepository

    @GetMapping("/{role}/list")
    @PreAuthorize("hasRole('ENGLISH_TEACHER') or hasRole('ADMIN')")
    fun getList(@PathVariable(value = "role") role: String): ArrayList<Profile> {
        var roleFull = ""
        when (role) {
            "student" -> {
                roleFull = "ROLE_STUDENT"
            }
            "teacher-english" -> {
                roleFull = "ROLE_ENGLISH_TEACHER"
            }
        }
        val roleStudent = roleRepository.findByName(roleFull)
        if (roleStudent.isPresent) {
            return profileRepository.findAllByRolesInAndDeletedAtIsNull(listOf(roleStudent.get()))
        }
        return arrayListOf()
    }

}
