package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonProperty
import javax.persistence.*

@Entity
@Table(name = "edu_status")
class EduStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private var id: Long = 0

    @Column(name="title")
    private var title: String = ""

    constructor(id: Long, title: String) {
        this.id = id
        this.title = title
    }

    fun getId() = this.id

    fun getTitle() = this.title

    class Json {
        @JsonProperty("id")
        val id: Long = 0

        @JsonProperty("title")
        var title: String = ""

    }

}
