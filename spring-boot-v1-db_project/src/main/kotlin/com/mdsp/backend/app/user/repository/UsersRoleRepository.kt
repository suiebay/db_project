package com.mdsp.backend.app.user.repository

import com.mdsp.backend.app.user.model.Role
import com.mdsp.backend.app.user.model.UsersRoles
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.*
import javax.transaction.Transactional

interface UsersRoleRepository : JpaRepository<UsersRoles, Long> {
    fun findByUserIdAndRoleId(@Param("userId") userId: UUID, @Param("roleId") roleId: Long): Optional<UsersRoles>

    fun findByUserId(@Param("user_id") userId: UUID): List<UsersRoles>

    fun findByRoleId(@Param("role_id") roleId: Long): Optional<UsersRoles>

    @Transactional
    fun deleteByUserId(@Param("user_id") userId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE users_roles SET deleted_at = CURRENT_TIMESTAMP WHERE user_id =:userId",
            nativeQuery = true)
    fun deletedAtByUserId( @Param("userId") userId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE users_roles SET deleted_at = null WHERE user_id =:userId",
            nativeQuery = true)
    fun returnAtByUserId( @Param("userId") userId: UUID)

}
