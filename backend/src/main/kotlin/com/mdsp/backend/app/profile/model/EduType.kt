package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import org.hibernate.annotations.GenericGenerator
import java.sql.Timestamp
import java.util.*
import javax.persistence.*


@Entity
@Table(name = "edu_type")
class EduType: DateAudit {
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

    @Column(name = "address")
    private var address: String? = null

    @Column(name = "status_id")
    private var statusId: Long = 1

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "status_id", referencedColumnName = "id", updatable = false, insertable = false)
    private lateinit var eduStatus: EduStatus

    constructor(
            id: UUID?,
            title: String,
            address: String,
            statusId: Long
    ) {
        this.id = id
        this.title = title
        this.address = address
        this.statusId = statusId
    }

    constructor(
            id: UUID?,
            title: String,
            address: String,
            statusId: Long,
            eduStatus: EduStatus
    ) {
        this.id = id
        this.title = title
        this.address = address
        this.statusId = statusId
        this.eduStatus = eduStatus
    }

    fun getId() = this.id

    fun getTitle() = this.title

    fun getAddress() = this.address

    fun getStatusId() = this.statusId

    fun getEduStatus() = this.eduStatus

    class Json {
        @JsonProperty("id")
        val id: UUID? = null

        @JsonProperty("title")
        var title: String? = null

        @JsonProperty("address")
        var address: String? = null

        @JsonProperty("status_id")
        var statusId: Long = 1

    }
}
