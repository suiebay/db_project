package com.mdsp.backend.app.system.model

import com.fasterxml.jackson.annotation.JsonProperty

class Json {
    data class Status(
        @JsonProperty("status")
        var status: Int = 0,

        @JsonProperty("message")
        var message: String? = null,

        @JsonProperty("value")
        var value: Any? = null
    )
}
