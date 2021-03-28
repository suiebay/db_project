package com.mdsp.backend.app.project.reads.model

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "reads_books")
@JsonIgnoreProperties(value = ["deletedAt"], allowGetters = true)
class Books: DateAudit {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "title")
    private var title: String? = null

    @Column(name = "author")
    private var author: String? = null

    @Column(name = "description", columnDefinition = "TEXT")
    private var description: String? = null

    @Column(name = "page_number")
    private var pageNumber: Int? = 0

    @Column(name = "rating")
    private var rating: Double? = 0.0

    @Column(name = "qr_code")
    private var qrCode: String? = null

    @Column(name = "img_storage", columnDefinition = "TEXT")
    private var imgStorage: String? = null

    @Column(name = "category")
    private var category: String? = null

    @Column(name = "rating_sum")
    private var ratingSum: Double? = 0.0

    @Column(name = "left_ratings")
    private var leftRatings: Int? = 0

    @Column(name = "deadline")
    private var deadline: Int? = 0

    constructor(
            id: UUID?,
            title: String?,
            author: String?,
            description: String?,
            pageNumber: Int?,
            imgStorage: String?,
            category: String?,
            deadline: Int?
    ) {
        this.id = id
        this.title = title
        this.author = author
        this.description = description
        this.pageNumber = pageNumber
        this.imgStorage = imgStorage
        this.category = category
        this.deadline = deadline
    }

    fun getId() = this.id
    fun getTitle() = this.title
    fun getAuthor() = this.author
    fun getDescription() = this.description
    fun getPageNumber() = this.pageNumber
    fun getRating() = this.rating
    fun getQrCode() = this.qrCode
    fun getImgStorage() = this.imgStorage
    fun getCategory() = this.category
    fun getRatingSum() = this.ratingSum
    fun getLeftRatings() = this.leftRatings
    fun getDeadline() = this.deadline


    fun setTitle(title: String) { this.title = title }
    fun setAuthor(author: String) { this.author = author }
    fun setDescription(description: String) { this.description = description }
    fun setPageNumber(pageNumber: Int) { this.pageNumber = pageNumber }
    fun setRating(rating: Double) { this.rating = rating }
    fun setQrCode(qrCode: String) { this.qrCode = qrCode }
    fun setImgStorage(imgStorage: String) { this.imgStorage = imgStorage }
    fun setCategory(category: String) { this.category = category }
    fun setRatingSum(ratingSum: Double?) { this.ratingSum = ratingSum }
    fun setLeftRatings(leftRatings: Int?) { this.leftRatings = leftRatings }
    fun setDeadline(deadline: Int?) { this.deadline = deadline }

    class Json {

        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("title")
        var title: String? = ""

        @JsonProperty("author")
        var author: String? = null

        @JsonProperty("description")
        var description: String? = null

        @JsonProperty("pageNumber")
        var pageNumber: Int? = 0

        @JsonProperty("rating")
        var rating: Double? = 0.0

        @JsonProperty("qrCode")
        var qrCode: String? = null

        @JsonProperty("imgStorage")
        var imgStorage: String? = null

        @JsonProperty("category")
        var category: String? = null

        @JsonProperty("ratingSum")
        var ratingSum: Double? = 0.0

        @JsonProperty("leftRatings")
        var leftRatings: Int? = 0

        @JsonProperty("deadline")
        var deadline: Int? = 0
    }
}
