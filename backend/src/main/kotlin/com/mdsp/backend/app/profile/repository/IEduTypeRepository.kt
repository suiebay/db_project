package com.mdsp.backend.app.profile.repository

import com.mdsp.backend.app.profile.model.EduType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*

interface IEduTypeRepository: JpaRepository<EduType, Long> {
    fun findFirstByTitleLikeAndTitleIsNotNullAndDeletedAtIsNull(@Param("title") title: String): Optional<EduType>

    fun getAllByDeletedAtIsNull(): List<EduType>
}
