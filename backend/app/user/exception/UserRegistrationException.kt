package com.mdsp.backend.app.user.exception

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus
import java.lang.RuntimeException

@ResponseStatus(HttpStatus.EXPECTATION_FAILED)
class UserRegistrationException: RuntimeException {
    private var user: String? = null
    private var message2: String? = null

    constructor(user: String, message2: String): super(kotlin.String.format("Failed to register User[%s] : '%s'", user, message2)) {
        this.user = user
        this.message2 = message2
    }
}