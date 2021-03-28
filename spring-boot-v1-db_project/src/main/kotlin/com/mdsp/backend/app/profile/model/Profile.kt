package com.mdsp.backend.app.profile.model

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import com.mdsp.backend.app.system.model.DateAudit
import com.mdsp.backend.app.user.model.Role
import com.vladmihalcea.hibernate.type.array.StringArrayType
import com.vladmihalcea.hibernate.type.array.UUIDArrayType
import com.vladmihalcea.hibernate.type.json.JsonBinaryType
import org.hibernate.annotations.GenericGenerator
import org.hibernate.annotations.Type
import org.hibernate.annotations.TypeDef
import org.hibernate.annotations.TypeDefs
import java.sql.Timestamp
import java.util.*
import javax.persistence.*
import kotlin.collections.ArrayList

@Entity(name = "Profiles")
@Table(name = "profiles")
@JsonIgnoreProperties(value = ["password", "isActive", "isBlocked", "path"], allowGetters = false)
@TypeDefs(
    TypeDef(
        name = "string-array",
        typeClass = StringArrayType::class
    ),
    TypeDef(
        name = "uuid-array",
        typeClass = UUIDArrayType::class
    ),
    TypeDef(
        name = "jsonb",
        typeClass = JsonBinaryType::class
    )
)
class Profile: DateAudit {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    @Column(name = "id", updatable = false, nullable = false)
    private var id: UUID? = null

    @Column(name = "first_name")
    private var firstName: String? = null

    @Column(name = "last_name")
    private var lastName: String? = null

    @Column(name = "middle_name")
    private var middleName: String? = null

    @Column(name = "birthday")
    private var birthday: Date? = null

    @Column(name = "gender")
    private var gender: Int = 1

    @Column(name = "grants")
    private var grants: Boolean = false

    @Column(name = "phone")
    private var phone: String? = null

    @Column(name = "skills")
    private var skills: String? = null

    @Column(name = "address")
    private var address: String? = null

    @Type(type = "jsonb")
    @Column(
        name = "social",
        columnDefinition = "jsonb"
    )
    private var social: String? = null

    @Column(name = "avatar", columnDefinition = "TEXT")
    private var avatar: String? = null

    @Column(name = "description", columnDefinition = "TEXT")
    private var description: String? = null

    @Column(name = "english_type")
    private var englishType: Int? = null

    @Column(name = "english_value")
    private var englishValue: String? = null

    @Column(name = "username", unique = true, nullable = false)
    private var username: String? = null

    @Column(name = "email")
    private var email: String? = null

    @Column(name = "password")
    private var password: String? = null

    @Column(name = "enabled")
    private var enabled: Boolean? = false

    @Column(name = "path")
    private var path: String? = null

    @Column(name = "group_id")
    private var groupId: UUID? = null

    @Column(name = "is_active")
    private var isActive: Boolean? = null

    @Column(name = "email_verified")
    private var emailVerified: Boolean? = null

    @Column(name = "reads_point")
    private var readsPoint: Int? = 0

    @Column(name = "reads_recommendation")
    private var readsRecommendation: String? = null

    @Column(name = "reads_finished_books")
    private var readsFinishedBooks: Int? = 0

    @Column(name = "reads_reviews_number")
    private var readsReviewNumber: Int? = 0

    @Column(name = "reads_group_id")
    private var readsGroupId: UUID? = null

    @Column(name = "login_attempts")
    private var loginAttempts: Int = 0

    @Column(name = "is_blocked")
    private var isBlocked: Timestamp? = null

    @Column(name = "language")
    private var language: String? = null

    @OneToMany(cascade = arrayOf(CascadeType.ALL))
    @JoinColumn(name = "profile_id", referencedColumnName = "id")
    private var education: Collection<Education>? = null

    @OneToMany(cascade = arrayOf(CascadeType.ALL))
    @JoinColumn(name = "profile_id", referencedColumnName = "id")
    private var experience: Collection<Experience>? = null

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = [JoinColumn(name = "user_id", referencedColumnName = "id")],
            inverseJoinColumns = [JoinColumn(name = "role_id", referencedColumnName = "id")]
    )
    private var roles: Collection<Role>? = null

    constructor() {}



    constructor(
            id: UUID?,
            firstName: String?,
            lastName: String?,
            middleName: String?,
            birthday: Date?,
            gender: Int,
            grants: Boolean,
            phone: String?,
            skills: String?,
            address: String?,
            social: String?,
            avatar: String?,
            description: String?,
            englishType: Int?,
            englishValue: String?,
            username: String?,
            email: String?,
            password: String?,
            enabled: Boolean?,
            emailVerified: Boolean
    ) {
        this.id = id
        this.firstName = firstName
        this.lastName = lastName
        this.middleName = middleName
        this.birthday = birthday
        this.gender = gender
        this.grants = grants
        this.phone = phone
        this.skills = skills
        this.address = address
        this.social = social
        this.avatar = avatar
        this.description = description
        this.englishType = englishType
        this.englishValue = englishValue
        this.username = username
        this.email = email
        this.password = password
        this.enabled = enabled
        this.emailVerified = emailVerified
    }


    fun markVerificationConfirmed() { setEmailVerified(true) }
    fun incrementLoginAttempts() { setLoginAttempts(this.loginAttempts + 1) }


    fun getId() = this.id
    fun getFirstName() = this.firstName
    fun getLastName() = this.lastName
    fun getMiddleName() = this.middleName
    fun getBirthday() = this.birthday
    fun getGender() = this.gender
    fun getGrants() = this.grants
    fun getPhone() = this.phone
    fun getSkills() = this.skills
    fun getAddress() = this.address
    fun getSocial() = this.social
    fun getAvatar() = this.avatar
    fun getDescription() = this.description
    fun getEnglishType() = this.englishType
    fun getEnglishValue() = this.englishValue
    fun getUsername() = this.username
    fun getEmail() = this.email
    fun getEnabled() = this.enabled
    fun getEducation() = this.education
    fun getExperience() = this.experience
    fun getRoles() = this.roles
    fun getPath() = this.path
    fun getGroupId() = this.groupId
    fun pwd() = this.password
    fun getEmailVerified() = this.emailVerified
    fun getLoginAttempts() = this.loginAttempts
    fun getIsBlocked() = this.isBlocked
    fun getIsActive() = this.isActive
    fun getReadsPoint() = this.readsPoint
    fun getReadsFinishedBooks() = this.readsFinishedBooks
    fun getReadsReviewNumber() = this.readsReviewNumber
    fun getReadsRecommendation() = this.readsRecommendation
    fun getLanguage() = this.language
    fun getReadsGroupId() = this.readsGroupId

    fun setFirstName(firstName: String?) { this.firstName = firstName }
    fun setLastName(lastName: String?) { this.lastName = lastName }
    fun setMiddleName(middleName: String?) { this.middleName = middleName }
    fun setBirthday(birthday: Date?) { this.birthday = birthday }
    fun setGender(gender: Int?) { this.gender = gender!! }
    fun setGrants(grants: Boolean?) { this.grants = grants!! }
    fun setPhone(phone: String?) { this.phone = phone }
    fun setSkills(skills: String?) { this.skills = skills }
    fun setAddress(address: String?) { this.address = address }
    fun setSocial(social: String?) { this.social = social }
    fun setAvatar(avatar: String?) { this.avatar = avatar }
    fun setDescription(description: String?) { this.description = description }
    fun setEnglishType(englishType: Int?) { this.englishType = englishType }
    fun setEnglishValue(englishValue: String?) { this.englishValue = englishValue }
    fun setUsername(username: String?) { this.username = username }
    fun setEmail(email: String?) { this.email = email }
    fun setEnabled(enabled: Boolean?) { this.enabled = enabled }
    fun setPassword(password: String?) { this.password = password }
    fun setPath(path: String?) { this.path = path }
    fun setGroupId(groupId: UUID?) { this.groupId = groupId }
    fun setEmailVerified(emailVerified: Boolean) { this.emailVerified = emailVerified }
    fun setLoginAttempts(loginAttempts: Int) { this.loginAttempts = loginAttempts }
    fun setIsBlocked(isBlocked: Timestamp?) { this.isBlocked = isBlocked }
    fun setIsActive(isActive: Boolean) { this.isActive = isActive }
    fun setReadsPoint(readsPoint: Int?) { this.readsPoint = readsPoint }
    fun setReadsFinishedBooks(readsFinishedBooks: Int?) { this.readsFinishedBooks = readsFinishedBooks }
    fun setReadsReviewNumber(readsReviewNumber: Int?) { this.readsReviewNumber = readsReviewNumber }
    fun setReadsRecommendation(readsRecommendation: String?) { this.readsRecommendation = readsRecommendation }
    fun setRoles(role: Collection<Role>?) { this.roles = role }
    fun setLanguage(language: String?) { this.language = language }
    fun setReadsGroupId(readsGroupId: UUID?) { this.readsGroupId = readsGroupId }


    fun getFIO(): String {
        var result: ArrayList<String> = arrayListOf<String>(this.lastName!!, this.firstName!!)
        if (this.middleName != null) {
            result.add(this.middleName!!)
        }
        return result.joinToString(" ").trim()
    }

    class Json {
        @JsonProperty("id")
        var id: UUID? = null

        @JsonProperty("firstName")
        var firstName: String = ""

        @JsonProperty("lastName")
        var lastName: String = ""

        @JsonProperty("middleName")
        var middleName: String? = null

        @JsonProperty("birthday")
        var birthday: Date? = null

        @JsonProperty("course")
        var course: String? = null

        @JsonProperty("gender")
        var gender: Int = 1

        @JsonProperty("genderString")
        var genderString: String? = null

        @JsonProperty("grants")
        var grants: Boolean = false

        @JsonProperty("phone")
        var phone: String? = null

        @JsonProperty("skills")
        var skills: String? = null

        @JsonProperty("address")
        var address: String? = null

        @JsonProperty("social")
        var social: String ? = null

        @JsonProperty("avatar")
        var avatar: String? = null

        @JsonProperty("userId")
        var userId: UUID? = null

        @JsonProperty("description")
        var description: String? = null

        @JsonProperty("english_type")
        var english_type: Int? = null

        @JsonProperty("english_value")
        var english_value: String? = null

        @JsonProperty("education")
        var education: ArrayList<Education.Json>? = null

        @JsonProperty("educationStr")
        var educationStr: String? = null

        @JsonProperty("experience")
        var experience: ArrayList<Experience>? = null

        @JsonProperty("username")
        var username: String? = null

        @JsonProperty("email")
        var email: String? = null

        @JsonProperty("password")
        var password: String? = null

        @JsonProperty("enabled")
        var enabled: Boolean? = false

        @JsonProperty("speciality")
        var speciality: String? = null

        @JsonProperty("deletedAt")
        var deletedAt: Timestamp? = null

        @JsonProperty("roles")
        var roles: ArrayList<Role>? = null

        @JsonProperty("path")
        var path: String? = null

        @JsonProperty("groupId")
        var groupId: UUID? = null

        @JsonProperty("readsPoint")
        var readsPoint: Int? = 0

        @JsonProperty("readsFinishedBooks")
        var readsFinishedBooks: Int? = 0

        @JsonProperty("readsReviewNumber")
        var readsReviewNumber: Int? = 0

        @JsonProperty("readsRecommendation")
        var readsRecommendation: ArrayList<ReadsRecommendationJson>? = null

        @JsonProperty("language")
        var language: String? = null

        constructor() {}

        constructor(
                firstName: String,
                lastName: String,
                middleName: String,
                birthday: Date,
                gender: Int,
                grants: Boolean,
                phone: String,
                skills: String,
                address: String,
                social: String,
                avatar: String,
                language: String
        ) {
            this.firstName = firstName
            this.lastName = lastName
            this.middleName = middleName
            this.birthday = birthday
            this.gender = gender
            this.grants = grants
            this.phone = phone
            this.skills = skills
            this.address = address
            this.social = social
            this.avatar = avatar
            this.language = language
        }
    }

    class Students{
        @JsonProperty("id")
        var id: String? = null

        @JsonProperty("fio")
        var fio: String? = null

        @JsonProperty("gender")
        var gender: Int = 1

        @JsonProperty("grants")
        var grants: Boolean = false

        @JsonProperty("title")
        var title: String? = null

        @JsonProperty("address")
        var address: String? = null

        @JsonProperty("speciality")
        var speciality: String? = null

        @JsonProperty("course")
        var course: Int? = 1

        constructor(
                id: String?,
                fio: String?,
                gender: Int,
                grants: Boolean,
                title: String?,
                address: String?,
                speciality: String?,
                course: Int?
        ) {
            this.id = id
            this.fio = fio
            this.gender = gender
            this.grants = grants
            this.title = title
            this.address = address
            this.speciality = speciality
            this.course = course
        }
    }

    class ReadsMentors{
        @JsonProperty("id")
        var id: String? = null

        @JsonProperty("fio")
        var fio: String? = null

        @JsonProperty("gender")
        var gender: Int = 1


        constructor(
                id: String?,
                fio: String?,
                gender: Int
        ) {
            this.id = id
            this.fio = fio
            this.gender = gender
        }
    }

    class ReadsUsers{
        @JsonProperty("id")
        var id: String? = null

        @JsonProperty("firstName")
        var firstName: String? = null

        @JsonProperty("lastName")
        var lastName: String? = null

        @JsonProperty("middleName")
        var middleName: String? = null

        @JsonProperty("readsFinishedBooks")
        var readsFinishedBooks: Int? = 0

        @JsonProperty("readsReviewNumber")
        var readsReviewNumber: Int? = 0

        @JsonProperty("readsPoint")
        var readsPoint: Int? = 0

        @JsonProperty("groupId")
        var groupId: String? = null

        @JsonProperty("avatar")
        var avatar: String? = null

        @JsonProperty("readsRecommendation")
        var readsRecommendation: String? = null

        @JsonProperty("email")
        var email: String? = null

        @JsonProperty("phone")
        var phone: String? = null

        @JsonProperty("gender")
        var gender: Int? = 1

        constructor(
                id: String?,
                firstName: String?,
                lastName: String?,
                middleName: String?,
                readsFinishedBooks: Int?,
                readsReviewNumber: Int?,
                readsPoint: Int?,
                groupId: String?,
                avatar: String?,
                readsRecommendation: String?,
                email: String?,
                phone: String?,
                gender: Int
        ) {
            this.id = id
            this.firstName = firstName
            this.lastName = lastName
            this.middleName = middleName
            this.readsFinishedBooks = readsFinishedBooks
            this.readsReviewNumber = readsReviewNumber
            this.readsPoint = readsPoint
            this.groupId = groupId
            this.avatar = avatar
            this.readsRecommendation = readsRecommendation
            this.email = email
            this.phone = phone
            this.gender = gender
        }
    }

    class ReadsRecommendationJson {

        @JsonProperty("bookName")
        var bookName: String? = null

        @JsonProperty("bookAuthor")
        var bookAuthor: String? = null

        constructor() {}

        constructor(
                bookName: String?,
                bookAuthor: String?
        ) {
            this.bookName = bookName
            this.bookAuthor = bookAuthor
        }
    }
}
