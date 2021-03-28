package com.mdsp.backend.app.profile.repository

import com.mdsp.backend.app.profile.model.Education
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.*
import javax.transaction.Transactional

interface IEducationRepository: JpaRepository<Education, Long> {
    fun findById(id: UUID): Optional<Education>

    @Query("SELECT DISTINCT speciality FROM educations WHERE deleted_at IS NULL", nativeQuery = true)
    fun getListSpeciality(): List<Any>
//    fun findProjects(): List<Array<Any?>?>?

    @Transactional
    fun deleteByProfileIdAndIdNotIn(@Param("profileId")  profileId: UUID, @Param("ids")  ids: ArrayList<UUID>)

    @Transactional
    fun deleteByProfileId(@Param("profileId")  profileId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE educations SET deleted_at = CURRENT_TIMESTAMP WHERE profile_id =:profileId",
            nativeQuery = true)
    fun deletedAtByProfileId( @Param("profileId") profileId: UUID)

    @Transactional
    @Modifying
    @Query(value = "UPDATE educations SET deleted_at = null WHERE profile_id =:profileId",
            nativeQuery = true)
    fun returnAtByProfileId( @Param("profileId") profileId: UUID)

}
