package com.mdsp.backend.app.project.reads.repository

import com.mdsp.backend.app.project.reads.model.ContactUs
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*
import kotlin.collections.ArrayList

interface IContactUsRepository: JpaRepository<ContactUs, Long> {
    fun findAllByDeletedAtIsNull(): ArrayList<ContactUs>

    fun findByIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<ContactUs>

    fun findByDescriptionAndDeletedAtIsNull(@Param("title")  title: String): Optional<ContactUs>
}
