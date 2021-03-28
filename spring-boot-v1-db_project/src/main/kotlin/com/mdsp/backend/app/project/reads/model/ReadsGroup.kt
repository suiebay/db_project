package com.mdsp.backend.app.project.reads.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.util.*
import javax.persistence.*
import kotlin.jvm.Transient

@Entity
@Table(name = "reads_group")
class ReadsGroup: DateAudit {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "title")
    private var title: String? = ""

    @Column(name = "mentor_id")
    private var mentorId: UUID? = null

    @Transient
    private var profileIds: String? = null

    constructor(
            id: UUID?,
            title: String?
    ) {
        this.id = id
        this.title = title
    }

    fun getId() = this.id
    fun getTitle() = this.title
    fun getMentorId() = this.mentorId

    fun setTitle(title: String) { this.title = title }
    fun setMentorId(mentorId: UUID?) { this.mentorId = mentorId }

    class Json {

        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("title")
        var title: String? = ""

        @JsonProperty("mentorId")
        var mentorId: UUID? = null

        @JsonProperty("profileIds")
        var profileIds: String? = ""

    }
}
