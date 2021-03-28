package com.mdsp.backend.app.user.model.payload

import javax.validation.constraints.NotNull

class User {
    private var username: String? = null

    private var email: String? = null

    @NotNull(message = "Login password cannot be blank")
    private lateinit var password: String

    constructor() {}

    constructor(username: String?, email: String?, password: String) {
        this.username = username
        this.email = email
        this.password = password
    }

    fun getUsername(): String? { return username }
    fun setUsername(username: String?) { this.username = username }

    fun getEmail(): String? { return email }
    fun setEmail(email: String?) { this.email = email }

    fun getPassword(): String? { return password }
    fun setPassword(password: String?) { this.password = password!! }
}