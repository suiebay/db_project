package com.mdsp.backend.app.profile.repository

import com.mdsp.backend.app.profile.model.Experience
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.*
import javax.transaction.Transactional

interface IExperienceRepository: JpaRepository<Experience, Long> {
    fun findById(id: UUID): Optional<Experience>

    @Transactional
    fun deleteByProfileIdAndIdNotIn(@Param("profileId")  profileId: UUID, @Param("ids")  ids: ArrayList<UUID>)

    @Transactional
    fun deleteByProfileId(@Param("profileId")  profileId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE experience SET deleted_at = CURRENT_TIMESTAMP WHERE profile_id =:profileId",
            nativeQuery = true)
    fun deletedAtByProfileId( @Param("profileId") profileId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE experience SET deleted_at = null WHERE profile_id =:profileId",
            nativeQuery = true)
    fun returnAtByProfileId( @Param("profileId") profileId: UUID)
}
