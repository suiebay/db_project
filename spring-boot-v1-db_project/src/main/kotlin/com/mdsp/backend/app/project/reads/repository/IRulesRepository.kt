package com.mdsp.backend.app.project.reads.repository

import com.mdsp.backend.app.project.reads.model.Rules
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*
import kotlin.collections.ArrayList

interface IRulesRepository: JpaRepository<Rules, Long> {
    fun findAllByDeletedAtIsNull(): ArrayList<Rules>

    fun findByIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<Rules>

    fun findByTitleAndDeletedAtIsNull(@Param("title")  title: String): Optional<Rules>
}
