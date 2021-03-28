package com.mdsp.backend.app.profile.repository

import com.mdsp.backend.app.profile.model.EduDegree
import com.mdsp.backend.app.profile.model.EduStatus
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*

interface IEduStatusRepository: JpaRepository<EduStatus, Long> {
    fun findByTitle(@Param("title") title: String): Optional<EduStatus>
}
