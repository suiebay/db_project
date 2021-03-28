package com.mdsp.backend.app.system.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.datasource.DriverManagerDataSource
import javax.sql.DataSource
import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "spring.datasource")
@Configuration("dataSourceConfig")
class DataSourceConfiguration {
    var driverClassName: String = ""
    var url: String? = null
    var userName: String? = null
    var password: String? = null
    var platform: String? = null

    @get:Bean(name = ["databaseoneconnection"])
    val dataBaseOneTemplate: DataSource
        get() {
            val dataSource = DriverManagerDataSource()
            dataSource.setDriverClassName(driverClassName)
            dataSource.url = url
            dataSource.username = userName
            dataSource.password = password
            return dataSource
        }
}
