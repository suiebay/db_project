package com.mdsp.backend.app.user.repository

import com.mdsp.backend.app.user.model.Role
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*

interface RoleRepository : JpaRepository<Role, Long> {

    fun findByName(@Param("name") name: String): Optional<Role>

}
