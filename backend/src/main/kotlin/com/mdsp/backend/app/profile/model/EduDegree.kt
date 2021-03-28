package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonProperty
import javax.persistence.*

@Entity
@Table(name = "edu_degree")
class EduDegree {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private var id: Long

    @Column(name = "title")
    private var title: String

    @Column(name = "order_num")
    private var orderNum: Int

    constructor(
            id: Long,
            title: String,
            order: Int
    ) {
        this.id = id
        this.title = title
        this.orderNum = order
    }

    fun getId() = this.id

    fun getTitle() = this.title

    fun getOrderNum() = this.orderNum


    class Json {
        //    @JsonProperty("id")
        //    val id: Long? = 0

        @JsonProperty("title")
        var title: String? = null

        @JsonProperty("order")
        var order: Int = 0
    }
}
