package com.mdsp.backend.app.project.reads.repository

import com.mdsp.backend.app.project.reads.model.ReadsGroup
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*
import kotlin.collections.ArrayList

interface IReadsGroupRepository: JpaRepository<ReadsGroup, Long> {

    fun findAllByDeletedAtIsNullOrderByTitle(): ArrayList<ReadsGroup>

    fun findByIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<ReadsGroup>

    fun findByTitleAndDeletedAtIsNull(@Param("title")  title: String): Optional<ReadsGroup>

    fun findByMentorIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<ReadsGroup>
}
