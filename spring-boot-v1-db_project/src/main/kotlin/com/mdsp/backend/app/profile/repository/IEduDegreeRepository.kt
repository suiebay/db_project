package com.mdsp.backend.app.profile.repository

import com.mdsp.backend.app.profile.model.EduDegree
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*

interface IEduDegreeRepository: JpaRepository<EduDegree, Long> {
    fun findByTitle(@Param("title") title: String): Optional<EduDegree>
}
