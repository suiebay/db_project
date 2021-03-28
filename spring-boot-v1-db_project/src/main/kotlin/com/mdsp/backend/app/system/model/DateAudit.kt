package com.mdsp.backend.app.system.model


import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.vladmihalcea.hibernate.type.array.StringArrayType
import com.vladmihalcea.hibernate.type.array.UUIDArrayType
import org.hibernate.annotations.Type
import org.hibernate.annotations.TypeDef
import org.hibernate.annotations.TypeDefs
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.io.Serializable
import java.util.Date
import java.sql.Timestamp
import javax.persistence.Column
import javax.persistence.EntityListeners
import javax.persistence.MappedSuperclass

@MappedSuperclass
@EntityListeners(AuditingEntityListener::class)
@JsonIgnoreProperties(value = ["deletedAt"], allowGetters = false)
@TypeDefs(
    TypeDef(
        name = "string-array",
        typeClass = StringArrayType::class
    )
)
abstract class DateAudit : Serializable {
    @CreatedDate
    @Column(
        name="created_at",
        nullable = false,
        updatable = false)
    private var createdAt: Timestamp = Timestamp(System.currentTimeMillis())

    @LastModifiedDate
    @Column(name="updated_at")
    private var updatedAt: Timestamp? = null

    @Column(name="deleted_at")
    private var deletedAt: Timestamp? = null

    @Type(type = "string-array")
    @Column(
        name = "creator",
        columnDefinition = "character varying(256)[]"
    )
    private var creator: Array<Array<String>>? = null

    @Type(type = "string-array")
    @Column(
        name = "editor",
        columnDefinition = "character varying(256)[]"
    )
    private var editor: Array<Array<String>>? = null

    open fun getCreatedAt(): Date? {
        return createdAt
    }

    open fun getUpdatedAt(): Timestamp? {
        return updatedAt
    }

    open fun setUpdatedAt(updatedAt: Timestamp?) {
        this.updatedAt = updatedAt
    }

    open fun getDeletedAt(): Timestamp? {
        return deletedAt
    }

    open fun setDeletedAt(deletedAt: Timestamp?) {
        this.deletedAt = deletedAt
    }

    open fun getCreator(): Array<Array<String>>? {
        return creator
    }

    open fun setCreator(creator: Array<Array<String>>?) {
        this.creator = creator
    }

    open fun getEditor(): Array<Array<String>>? {
        return editor
    }

    open fun setEditor(editor: Array<Array<String>>?) {
        this.editor = editor
    }

}
