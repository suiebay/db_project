package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.sql.Timestamp
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "educations")
class Education: DateAudit{
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "profile_id")
    private var profileId: UUID? = null

    @Column(name = "year_start")
    private var yearStart: Date? = null

    @Column(name = "year_end")
    private var yearEnd: Date? = null

    @Column(name = "gpa")
    private var gpa: Float? = null

    @Column(name = "speciality")
    private var speciality: String

    @Column(name="course")
    private var course: Int

    @Column(name="edu_id")
    private var eduId: UUID? = null

    @Column(name="status_id")
    private var statusId: Long = 0

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "edu_id", referencedColumnName = "id", updatable = false, insertable = false)
    private var edu_type: EduType? = null

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "status_id", referencedColumnName = "id", updatable = false, insertable = false)
    private var edu_status: EduDegree? = null

    constructor(
            id: UUID?,
            yearStart: Date?,
            yearEnd: Date?,
            gpa: Float?,
            speciality: String,
            course: Int,
            eduId: UUID?,
            statusId: Long,
            edu_type: EduType,
            edu_status: EduDegree
    ) {
        this.id = id
        this.yearStart = yearStart
        this.yearEnd = yearEnd
        this.gpa = gpa
        this.speciality = speciality
        this.course = course
        this.eduId = eduId
        this.statusId = statusId
        this.edu_type = edu_type
        this.edu_status = edu_status
    }

    constructor(
            id: UUID?,
            profileId: UUID?,
            yearStart: Date?,
            yearEnd: Date?,
            gpa: Float?,
            speciality: String,
            course: Int,
            eduId: UUID?,
            statusId: Long
    ) {
        this.id = id
        this.profileId = profileId
        this.yearStart = yearStart
        this.yearEnd = yearEnd
        this.gpa = gpa
        this.speciality = speciality
        this.course = course
        this.eduId = eduId
        this.statusId = statusId
    }

    fun getId() = this.id

    //fun getProfileId() = this.profileId

    fun getYearStart() = this.yearStart

    fun getYearEnd() = this.yearEnd

    fun getGpa() = this.gpa

    fun getSpeciality() = this.speciality

    fun getCourse() = this.course

    fun getEduId() = this.eduId

    fun getStatusId() = this.statusId

    fun getEduType() = this.edu_type

    fun getEduStatus() = this.edu_status

    class Json {
        @JsonProperty("id")
        val id: UUID? = null

        @JsonProperty("yearStart")
        var yearStart: Date? = null

        @JsonProperty("yearEnd")
        var yearEnd: Date? = null

        @JsonProperty("gpa")
        var gpa: Float? = null

        @JsonProperty("speciality")
        var speciality: String = ""

        @JsonProperty("course")
        var course: Int = 1

        @JsonProperty("eduId")
        var eduId: UUID? = null

        @JsonProperty("statusId")
        var eduStatusId: Long = 0

        @JsonProperty("eduType")
        var eduType: EduType.Json? = null

        @JsonProperty("eduStatus")
        var eduStatus: EduStatus.Json? = null

    }

}

