package com.mdsp.backend.app.user.model

import javax.persistence.*

@Entity
@Table(name = "roles")
class Role {

        @Id
        @GeneratedValue(strategy = GenerationType.AUTO)
        val id: Long = 0

        @Column(name = "name")
        var name: String = ""
}
