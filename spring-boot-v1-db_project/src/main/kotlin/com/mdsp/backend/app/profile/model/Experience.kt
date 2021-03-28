package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.sql.Timestamp
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "experience")
class Experience: DateAudit {
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

    @Column(name = "title")
    private var title: String? = null

    @Column(name = "speciality")
    private var speciality: String? = null

    @Column(name = "year_start")
    private var yearStart: Date? = null

    @Column(name = "year_end")
    private var yearEnd: Date? = null

    constructor(
            id: UUID?,
            profileId: UUID?,
            title: String?,
            speciality: String?,
            yearStart: Date?,
            yearEnd: Date?
    ) {
        this.id = id
        this.profileId = profileId
        this.title = title
        this.speciality = speciality
        this.yearStart = yearStart
        this.yearEnd = yearEnd
    }

    fun getId() = this.id

    fun getProfileId() = this.profileId

    fun getTitle() = this.title

    fun getSpeciality() = this.speciality

    fun getYearStart() = this.yearStart

    fun getYearEnd() = this.yearEnd

    class Json {
        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("profile_id")
        var profile_id: UUID? = null

        @JsonProperty("title")
        var title: String? = null

        @JsonProperty("speciality")
        var speciality: String? = null

        @JsonProperty("year_start")
        var year_start: Date? = null

        @JsonProperty("year_end")
        var year_end: Date? = null

    }
}

