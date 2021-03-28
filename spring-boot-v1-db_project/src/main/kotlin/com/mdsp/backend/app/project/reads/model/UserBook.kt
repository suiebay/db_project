package com.mdsp.backend.app.project.reads.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.sql.Timestamp
import java.util.*
import javax.persistence.*
import kotlin.jvm.Transient

@Entity
@Table(name = "reads_user_book")
class UserBook: DateAudit {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "book_id")
    private var bookId: UUID? = null

    @Column(name = "profile_id")
    private var profileId: UUID? = null

    @Column(name = "start_date")
    private var startDate: Timestamp? = null

    @Column(name = "end_date")
    private var endDate: Timestamp? = null

    @Column(name = "book_review", columnDefinition="TEXT")
    private var bookReview: String? = null

    @Column(name = "book_rating")
    private var bookRating: Double? = null

    @Column(name = "got_point")
    private var gotPoint: Int? = 0

    @Column(name = "chance_number")
    private var chanceNumber: Int? = 0

    @Column(name = "verified")
    private var verified: Boolean? = null

    @Column(name = "quiz_acl")
    private var quizAcl: Boolean? = false

    @Column(name = "check_rated")
    private var checkRated: Boolean? = null

    @Column(name = "last_notification")
    private var lastNotification: Timestamp? = null

    @Transient
    private var adminPoint: Int? = 0

    constructor(
            id: UUID?,
            bookId: UUID?,
            profileId: UUID?,
            startDate: Timestamp?,
            endDate: Timestamp?,
            bookReview: String?,
            bookRating: Double?,
            gotPoint: Int?
    ) {
        this.id = id
        this.bookId = bookId
        this.profileId = profileId
        this.startDate = startDate
        this.endDate = endDate
        this.bookReview = bookReview
        this.bookRating = bookRating
        this.gotPoint = gotPoint
    }

    fun getId() = this.id
    fun getBookId() = this.bookId
    fun getProfileId() = this.profileId
    fun getStartDate() = this.startDate
    fun getEndDate() = this.endDate
    fun getBookReview() = this.bookReview
    fun getBookRating() = this.bookRating
    fun getGotPoint() = this.gotPoint
    fun getAdminPoint() = this.adminPoint
    fun getChanceNumber() = this.chanceNumber
    fun getVerified() = this.verified
    fun getQuizAcl() = this.quizAcl
    fun getCheckRated() = this.checkRated
    fun getLastNotification() = this.lastNotification

    fun setBookId(bookId: UUID?) { this.bookId = bookId }
    fun setProfileId(profileId: UUID?) { this.profileId = profileId }
    fun setStartDate(startDate: Timestamp?) { this.startDate = startDate }
    fun setEndDate(endDate: Timestamp?) { this.endDate = endDate }
    fun setBookReview(bookReview: String?) { this.bookReview = bookReview }
    fun setBookRating(bookRating: Double?) { this.bookRating = bookRating }
    fun setGotPoint(gotPoint: Int?) { this.gotPoint = gotPoint }
    fun setAdminPoint(adminPoint: Int?) { this.adminPoint = adminPoint }
    fun setChanceNumber(chanceNumber: Int?) { this.chanceNumber = chanceNumber }
    fun setVerified(verified: Boolean?) { this.verified = verified }
    fun setQuizAcl(quizAcl: Boolean?) { this.quizAcl = quizAcl }
    fun setCheckRated(checkRated: Boolean?) { this.checkRated = checkRated }
    fun setLastNotification(lastNotification: Timestamp?) { this.lastNotification = lastNotification }

    class Json {

        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("bookId")
        var bookId: UUID? = null

        @JsonProperty("profileId")
        var profileId: UUID? = null

        @JsonProperty("startDate")
        var startDate: Timestamp? = null

        @JsonProperty("endDate")
        var endDate: Timestamp? = null

        @JsonProperty("bookReview")
        var bookReview: String? = null

        @JsonProperty("bookRating")
        var bookRating: Double? = 0.0

        @JsonProperty("gotPoint")
        var gotPoint: Int? = 0

        @JsonProperty("adminPoint")
        var adminPoint: Int? = 0

        @JsonProperty("chanceNumber")
        var chanceNumber: Int? = 0

        @JsonProperty("verified")
        var verified: Boolean? = null

        @JsonProperty("checkRated")
        var checkRated: Boolean? = null

        @JsonProperty("lastNotification")
        var lastNotification: Timestamp? = null

    }
}
