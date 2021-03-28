package com.mdsp.backend.app.project.reads.repository

import com.mdsp.backend.app.project.reads.model.Books
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*
import kotlin.collections.ArrayList

interface IBooksRepository: JpaRepository<Books, Long> {
    fun findAllByDeletedAtIsNull(): ArrayList<Books>

    fun findAllByDeletedAtIsNull(page: Pageable): Page<Books>

    fun findAllByCategoryAndDeletedAtIsNull(@Param("category")  category: String): ArrayList<Books>

    fun findAllByTitleIgnoreCaseContainsOrAuthorIgnoreCaseContainsAndDeletedAtIsNull(@Param("title")  title: String, @Param("author")  author: String): ArrayList<Books>

    fun findByIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<Books>

    fun findById(@Param("id")  id: UUID): Optional<Books>

    fun findByTitleAndDeletedAtIsNull(@Param("title")  title: String): Optional<Books>
}
