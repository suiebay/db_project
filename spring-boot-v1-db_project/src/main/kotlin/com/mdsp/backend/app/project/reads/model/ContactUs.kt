package com.mdsp.backend.app.project.reads.model

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "reads_contact_us")
@JsonIgnoreProperties(value = ["deletedAt"], allowGetters = true)
class ContactUs: DateAudit {
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "description")
    private var description: String? = null

    @Column(name = "user_id")
    private var userId: UUID? = null

    constructor(
            id: UUID?,
            description: String?,
            userId: UUID?
    ) {
        this.id = id
        this.description = description
        this.userId = userId
    }

    fun getId() = this.id
    fun getDescription() = this.description
    fun getUserId() = this.userId

    fun setDescription(description: String) { this.description = description }

    class Json {

        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("description")
        var description: String? = ""

        @JsonProperty("userId")
        var userId: UUID? = null
    }
}
