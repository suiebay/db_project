package com.mdsp.backend.app.project.reads.repository

import com.mdsp.backend.app.project.reads.model.UserBook
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.repository.query.Param
import java.util.*
import kotlin.collections.ArrayList

interface IUserBookRepository: JpaRepository<UserBook, Long> {
    fun findAllByBookIdAndDeletedAtIsNull(@Param("bookId")  bookId: UUID): ArrayList<UserBook>

    fun findAllByProfileIdAndDeletedAtIsNull(@Param("profileId")  profileId: UUID): ArrayList<UserBook>

    fun findAllByProfileIdAndEndDateIsNotNullAndDeletedAtIsNull(@Param("profileId")  profileId: UUID): ArrayList<UserBook>

    fun findAllByProfileIdAndEndDateIsNotNull(@Param("profileId")  profileId: UUID): ArrayList<UserBook>

    fun findAllByBookIdAndEndDateIsNullAndDeletedAtIsNull(@Param("bookId")  bookId: UUID): ArrayList<UserBook>

    fun findAllByBookIdAndEndDateIsNotNullAndDeletedAtIsNull(@Param("bookId")  bookId: UUID): ArrayList<UserBook>

    fun findByProfileIdAndBookIdAndDeletedAtIsNull(@Param("profileId")  profileId: UUID, @Param("bookId")  bookId: UUID): Optional<UserBook>

    fun findByIdAndDeletedAtIsNull(@Param("id")  id: UUID): Optional<UserBook>

    fun findById(@Param("id")  id: UUID): Optional<UserBook>

    fun findByProfileIdAndDeletedAtIsNull(@Param("profileId")  profileId: UUID): Optional<UserBook>

    fun findByProfileIdAndEndDateIsNullAndDeletedAtIsNull(@Param("profileId") profileId: UUID): Optional<UserBook>

    fun findByProfileIdAndEndDateIsNull(@Param("profileId") profileId: UUID): Optional<UserBook>

    fun findByIdAndBookReviewIsNullAndDeletedAtIsNull(@Param("Id") id: UUID): Optional<UserBook>

    fun findByIdAndBookReviewIsNotNullAndDeletedAtIsNull(@Param("Id") id: UUID): Optional<UserBook>

    fun findAllByDeletedAtIsNull(): ArrayList<UserBook>
}
