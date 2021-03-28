package com.mdsp.backend.app.project.reads.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.util.*
import javax.persistence.*

@Entity
@Table(name = "reads_rules")
class Rules: DateAudit {
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

    @Column(name = "description", columnDefinition = "TEXT")
    private var description: String? = null

    constructor(
            id: UUID?,
            title: String?,
            description: String?
    ) {
        this.id = id
        this.title = title
        this.description = description
    }

    fun getId() = this.id
    fun getTitle() = this.title
    fun getDescription() = this.description

    fun setTitle(title: String) { this.title = title }
    fun setDescription(description: String) { this.description = description }

    class Json {

        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("title")
        var title: String? = ""

        @JsonProperty("description")
        var description: String? = null

    }
}
