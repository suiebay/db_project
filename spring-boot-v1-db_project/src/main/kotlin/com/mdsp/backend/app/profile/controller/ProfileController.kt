package com.mdsp.backend.app.profile.controller

import com.mdsp.backend.app.profile.model.*
import com.mdsp.backend.app.profile.repository.*
import com.mdsp.backend.app.system.model.Json
import com.mdsp.backend.app.user.model.Role
import com.mdsp.backend.app.user.model.UsersRoles
import com.mdsp.backend.app.user.repository.RoleRepository
import com.mdsp.backend.app.user.repository.UsersRoleRepository
import com.mdsp.backend.app.user.security.service.ResponseMessage
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.sql.Timestamp
import java.util.*
import javax.validation.Valid
import kotlin.collections.ArrayList
import org.springframework.data.domain.PageRequest as PageRequest1


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 1800)
@RestController
@RequestMapping("/api")
class ProfileController {

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @GetMapping("/profiles/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getPersons(@PathVariable id: UUID): Optional<Profile> {
        var _profile = profileRepository.findByIdAndDeletedAtIsNull(id)
        if (_profile.isPresent) {
            _profile.get().setPassword("")
        }
        return _profile
    }

    @GetMapping("/myprofile")
    @PreAuthorize("isAuthenticated()")
    fun getMyProfile(authentication: Authentication): Optional<Profile> {
        var _profile = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name)
        if (_profile.isPresent) {
            _profile.get().setPassword("")
        }
        return _profile
    }

//    @Autowired
//    lateinit var engGroupRepository: IEnglishGroupRepository

    @Autowired
    lateinit var usersRoleRepository: UsersRoleRepository

    @Autowired
    lateinit var eduTypeRepository: IEduTypeRepository

    @Autowired
    lateinit var eduStatusRepository: IEduStatusRepository

    @Autowired
    lateinit var eduDegreeRepository: IEduDegreeRepository

    @Autowired
    lateinit var encoder: PasswordEncoder

    @Autowired
    lateinit var roleRepository: RoleRepository

    @Autowired
    lateinit var educationRepository: IEducationRepository

    @Autowired
    lateinit var experienceRepository: IExperienceRepository

//    @GetMapping("/profiles")
//    @PreAuthorize("hasRole('ADMIN')")
//    @ResponseBody
//    fun getProfileAllDetails(): List<ProfileAllDetails> {
//        return profileAllDetails.getAllByDeletedAtIsNull()
//    }

    @PostMapping("/profile/change-avatar")
    @PreAuthorize("isAuthenticated()")
    fun updateRules(@Valid @RequestBody newProfile: Profile.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val profileCandidate: Optional<Profile> = profileRepository.findByIdAndDeletedAtIsNull(newProfile.id!!)
        if (profileCandidate.isPresent) {
            if(newProfile.avatar !== null) profileCandidate.get().setAvatar(newProfile.avatar!!)
            profileCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))
            profileRepository.save(profileCandidate.get())
        } else {
            status.status = 0
            status.message = "Profile does not exist"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Profile avatar updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @GetMapping("/reads/user-place/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getReadersPlace(@PathVariable(value = "id") userId: UUID): ResponseEntity<*> {
        val readsUsers: ArrayList<Profile> = profileRepository.findAllReadersPlace("ROLE_STUDENT")
        var counter = 0

        var profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(userId);

        if(profileCandidate.isPresent) {
            for (readsUser in readsUsers) {
                counter++;
                if (readsUser.getId() == userId) {
                    return ResponseEntity(counter, HttpStatus.OK)
                }
            }
            return ResponseEntity("ADMIN", HttpStatus.OK)
        }
        return ResponseEntity("NOT FOUND", HttpStatus.OK)
    }

    @GetMapping("/reads/user-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: PageRequest1 = org.springframework.data.domain.PageRequest.of(page - 1, 20)
        val readsUsers: Page<Profile> = profileRepository.findAllReaders("ROLE_STUDENT", page)
        var readersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(readsUser in readsUsers) {
            var st = Profile.ReadsUsers(
                    readsUser.getId().toString(),
                    readsUser.getFirstName(),
                    readsUser.getLastName(),
                    readsUser.getMiddleName(),
                    readsUser.getReadsFinishedBooks(),
                    readsUser.getReadsReviewNumber(),
                    readsUser.getReadsPoint(),
                    readsUser.getGroupId().toString(),
                    readsUser.getAvatar(),
                    readsUser.getReadsRecommendation(),
                    readsUser.getEmail(),
                    readsUser.getPhone(),
                    readsUser.getGender()
            )
            readersList.add(st)
        }
        return ResponseEntity(readersList, HttpStatus.OK)
    }

    @GetMapping("/reads/admin-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getAdminReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: PageRequest1 = org.springframework.data.domain.PageRequest.of(page - 1, 20)
        val readsAdmins: Page<Profile> = profileRepository.findAllReaders("ROLE_READS_MENTOR", page)
        var readersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(readsUser in readsAdmins) {
            var st = Profile.ReadsUsers(
                    readsUser.getId().toString(),
                    readsUser.getFirstName(),
                    readsUser.getLastName(),
                    readsUser.getMiddleName(),
                    readsUser.getReadsFinishedBooks(),
                    readsUser.getReadsReviewNumber(),
                    readsUser.getReadsPoint(),
                    readsUser.getGroupId().toString(),
                    readsUser.getAvatar(),
                    readsUser.getReadsRecommendation(),
                    readsUser.getEmail(),
                    readsUser.getPhone(),
                    readsUser.getGender()
            )
            readersList.add(st)
        }
        return ResponseEntity(readersList, HttpStatus.OK)
    }

    @RequestMapping(value = ["/reads/user-list/{page}/search"], method = [RequestMethod.GET])
    @PreAuthorize("isAuthenticated()")
    fun getReadersListSearch(@PathVariable(value = "page") page: Int, @RequestParam("word") word: String): ResponseEntity<*>{
        if(word.length >= 3) {
            val page: PageRequest1 = org.springframework.data.domain.PageRequest.of(page - 1, 20)
            var profilesCandidate: Page<Profile> = profileRepository.findAllReadersBySearch("%$word%", "ROLE_STUDENT", page)
            var readersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

            for (readsUser in profilesCandidate) {
                var st = Profile.ReadsUsers(
                        readsUser.getId().toString(),
                        readsUser.getFirstName(),
                        readsUser.getLastName(),
                        readsUser.getMiddleName(),
                        readsUser.getReadsFinishedBooks(),
                        readsUser.getReadsReviewNumber(),
                        readsUser.getReadsPoint(),
                        readsUser.getGroupId().toString(),
                        readsUser.getAvatar(),
                        readsUser.getReadsRecommendation(),
                        readsUser.getEmail(),
                        readsUser.getPhone(),
                        readsUser.getGender()
                )
                readersList.add(st)
            }

            return ResponseEntity(readersList, HttpStatus.OK)
        } else {
            return ResponseEntity("Word length is smaller than 3", HttpStatus.BAD_REQUEST)
        }
    }

    @GetMapping("/reads/gold-user-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getGoldReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: org.springframework.data.domain.PageRequest = org.springframework.data.domain.PageRequest.of(page - 1, 20)
        val readsUsers: Page<Profile> = profileRepository.findGoldReaders("ROLE_STUDENT", page)
        var goldReadersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(goldReadsUser in readsUsers) {
            var st = Profile.ReadsUsers(
                    goldReadsUser.getId().toString(),
                    goldReadsUser.getFirstName(),
                    goldReadsUser.getLastName(),
                    goldReadsUser.getMiddleName(),
                    goldReadsUser.getReadsFinishedBooks(),
                    goldReadsUser.getReadsReviewNumber(),
                    goldReadsUser.getReadsPoint(),
                    goldReadsUser.getGroupId().toString(),
                    goldReadsUser.getAvatar(),
                    goldReadsUser.getReadsRecommendation(),
                    goldReadsUser.getEmail(),
                    goldReadsUser.getPhone(),
                    goldReadsUser.getGender()
            )
            goldReadersList.add(st)
        }
        return ResponseEntity(goldReadersList, HttpStatus.OK)
    }

    @GetMapping("/reads/silver-user-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getSilverReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: org.springframework.data.domain.PageRequest = org.springframework.data.domain.PageRequest.of(page - 1, 20)
//        print(profileRepository.findSilverReaders())
        val readsUsers: Page<Profile> = profileRepository.findSilverReaders("ROLE_STUDENT", page)
        var silverReadersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(goldReadsUser in readsUsers) {
            var st = Profile.ReadsUsers(
                    goldReadsUser.getId().toString(),
                    goldReadsUser.getFirstName(),
                    goldReadsUser.getLastName(),
                    goldReadsUser.getMiddleName(),
                    goldReadsUser.getReadsFinishedBooks(),
                    goldReadsUser.getReadsReviewNumber(),
                    goldReadsUser.getReadsPoint(),
                    goldReadsUser.getGroupId().toString(),
                    goldReadsUser.getAvatar(),
                    goldReadsUser.getReadsRecommendation(),
                    goldReadsUser.getEmail(),
                    goldReadsUser.getPhone(),
                    goldReadsUser.getGender()
            )
            silverReadersList.add(st)
        }
        return ResponseEntity(silverReadersList, HttpStatus.OK)
    }

    @GetMapping("/reads/bronze-user-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getBronzeReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: org.springframework.data.domain.PageRequest = org.springframework.data.domain.PageRequest.of(page - 1, 20)
        val readsUsers: Page<Profile> = profileRepository.findBronzeReaders("ROLE_STUDENT", page);
        var bronzeReadersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(goldReadsUser in readsUsers) {
            var st = Profile.ReadsUsers(
                    goldReadsUser.getId().toString(),
                    goldReadsUser.getFirstName(),
                    goldReadsUser.getLastName(),
                    goldReadsUser.getMiddleName(),
                    goldReadsUser.getReadsFinishedBooks(),
                    goldReadsUser.getReadsReviewNumber(),
                    goldReadsUser.getReadsPoint(),
                    goldReadsUser.getGroupId().toString(),
                    goldReadsUser.getAvatar(),
                    goldReadsUser.getReadsRecommendation(),
                    goldReadsUser.getEmail(),
                    goldReadsUser.getPhone(),
                    goldReadsUser.getGender()
            )
            bronzeReadersList.add(st)
        }
        return ResponseEntity(bronzeReadersList, HttpStatus.OK)
    }

    @GetMapping("/reads/unrated-user-list/{page}")
    @PreAuthorize("isAuthenticated()")
    fun getUnratedReadersList(@PathVariable(value = "page") page: Int): ResponseEntity<*> {
        val page: org.springframework.data.domain.PageRequest = org.springframework.data.domain.PageRequest.of(page - 1, 20)
        val readsUsers: Page<Profile> = profileRepository.findUnratedReaders("ROLE_STUDENT", page);
        var unratedReadersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(goldReadsUser in readsUsers) {
            var st = Profile.ReadsUsers(
                    goldReadsUser.getId().toString(),
                    goldReadsUser.getFirstName(),
                    goldReadsUser.getLastName(),
                    goldReadsUser.getMiddleName(),
                    goldReadsUser.getReadsFinishedBooks(),
                    goldReadsUser.getReadsReviewNumber(),
                    goldReadsUser.getReadsPoint(),
                    goldReadsUser.getGroupId().toString(),
                    goldReadsUser.getAvatar(),
                    goldReadsUser.getReadsRecommendation(),
                    goldReadsUser.getEmail(),
                    goldReadsUser.getPhone(),
                    goldReadsUser.getGender()
            )
            unratedReadersList.add(st)
        }
        return ResponseEntity(unratedReadersList, HttpStatus.OK)
    }

    @GetMapping("/reads/group-user-list/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getGroupReadersList(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        val groupUsers: ArrayList<Profile> = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNullOrderByReadsPointDescReadsFinishedBooksDesc(id)
        var groupReadersList: ArrayList<Profile.ReadsUsers> = arrayListOf()

        for(groupUser in groupUsers) {
            var st = Profile.ReadsUsers(
                    groupUser.getId().toString(),
                    groupUser.getFirstName(),
                    groupUser.getLastName(),
                    groupUser.getMiddleName(),
                    groupUser.getReadsFinishedBooks(),
                    groupUser.getReadsReviewNumber(),
                    groupUser.getReadsPoint(),
                    groupUser.getGroupId().toString(),
                    groupUser.getAvatar(),
                    groupUser.getReadsRecommendation(),
                    groupUser.getEmail(),
                    groupUser.getPhone(),
                    groupUser.getGender()
            )
            groupReadersList.add(st)
        }
        return ResponseEntity(groupReadersList, HttpStatus.OK)
    }

    @GetMapping("/profiles/noenglish/list")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getProfileNoEnglishList(): ArrayList<Profile.Students> {
        var _students = profileRepository.getListStudents("ROLE_STUDENT")
        var _studentList: ArrayList<Profile.Students> = arrayListOf()

        var status = Json.Status()
        status.status = 0
        status.message = "Disable"
        var ids: String = ""
//        for (_student in _students) {
//            val englishGroup: Optional<EnglishGroup> = engGroupRepository.findByTeamleadIdAndStatusAndDeletedAtIsNull(UUID.fromString(_student[0].toString()), 1)
//            if(englishGroup.isPresent){
//                ids += englishGroup.get().getProfileIds().toString()
//                ids += ","
//            }
//        }
        for (_student in _students) {

            if(!ids.contains(_student[0].toString())) {
                var st = Profile.Students(
                        id = _student[0].toString(),
                        fio = _student[1].toString(),
                        gender = _student[2].toString().toInt(),
                        grants = _student[3].toString().toBoolean(),
                        title = _student[4].toString(),
                        address = _student[5].toString(),
                        speciality = _student[6].toString(),
                        course = _student[7].toString().toInt()
                )
                _studentList.add(st)
            }
        }
        return _studentList
    }

    @GetMapping("/profiles/nogroup/list")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getProfileNoGroupList(): ArrayList<Profile.Students>{
        var _students = profileRepository.getListStudents("ROLE_STUDENT")
        var _studentList: ArrayList<Profile.Students> = arrayListOf()

        for (_student in _students) {
            val profile: Optional<Profile> = profileRepository.findByIdAndPathIsNullAndDeletedAtIsNull(UUID.fromString(_student[0].toString()))
            if(profile.isPresent) {
                var st = Profile.Students(
                        id = _student[0].toString(),
                        fio = _student[1].toString(),
                        gender = _student[2].toString().toInt(),
                        grants = _student[3].toString().toBoolean(),
                        title = _student[4].toString(),
                        address = _student[5].toString(),
                        speciality = _student[6].toString(),
                        course = _student[7].toString().toInt()
                )
                _studentList.add(st)
            }
        }
        return _studentList
    }

    @GetMapping("/profiles/roles/list")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getProfileAllDetails(): ArrayList<Profile.Students>{
        var _students = profileRepository.getListStudents("ROLE_STUDENT")
        var _studentList: ArrayList<Profile.Students> = arrayListOf()

        for (_student in _students) {
            var st = Profile.Students(
                    id = _student[0].toString(),
                    fio = _student[1].toString(),
                    gender = _student[2].toString().toInt(),
                    grants = _student[3].toString().toBoolean(),
                    title = _student[4].toString(),
                    address = _student[5].toString(),
                    speciality = _student[6].toString(),
                    course = _student[7].toString().toInt()
            )
            _studentList.add(st)
        }
        return _studentList
    }

    @GetMapping("/profiles/all/list")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getAllStdMtrDetails(): ArrayList<Profile.Students>{
        var _students = profileRepository.getListStudents("ROLE_STUDENT")
        var _mentorStudents = profileRepository.getListStudents("ROLE_READS_MENTOR")
        var _studentList: ArrayList<Profile.Students> = arrayListOf()

        for (_student in _students) {
            var st = Profile.Students(
                    id = _student[0].toString(),
                    fio = _student[1].toString(),
                    gender = _student[2].toString().toInt(),
                    grants = _student[3].toString().toBoolean(),
                    title = _student[4].toString(),
                    address = _student[5].toString(),
                    speciality = _student[6].toString(),
                    course = _student[7].toString().toInt()
            )
            _studentList.add(st)
        }

        for (_student in _mentorStudents) {
            var st = Profile.Students(
                    id = _student[0].toString(),
                    fio = _student[1].toString(),
                    gender = _student[2].toString().toInt(),
                    grants = _student[3].toString().toBoolean(),
                    title = _student[4].toString(),
                    address = _student[5].toString(),
                    speciality = _student[6].toString(),
                    course = _student[7].toString().toInt()
            )
            _studentList.add(st)
        }
        return _studentList
    }

    @GetMapping("/profiles/roles/readsmentorlist")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseBody
    fun getReadsMentorDetails(): ArrayList<Profile.ReadsMentors> {
        var mentors = profileRepository.getListMentors("ROLE_READS_MENTOR")
        var mentorList: ArrayList<Profile.ReadsMentors> = arrayListOf()

        for (_mentor in mentors) {
            var st = Profile.ReadsMentors(
                    id = _mentor[0].toString(),
                    fio = _mentor[1].toString(),
                    gender = _mentor[2].toString().toInt()
            )
            mentorList.add(st)
        }
        return mentorList
    }

    @GetMapping("/education/types")
    @PreAuthorize("isAuthenticated()")
    fun getEducationTypes(): List<EduType> {
        val aRes = eduTypeRepository.getAllByDeletedAtIsNull()
//        val gson = Gson()
//        Util.createTmpFileMdsp(gson.toJson(aRes), "/Users/bekzat/.bitnami/stackman/machines/xampp/volumes/root/htdocs/tmp.mds/")
        return aRes
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/roles")
    fun getRoles() = roleRepository.findAll()

    @GetMapping("/edu/specs")
    @PreAuthorize("isAuthenticated()")
    fun getListSpecs() = educationRepository.getListSpeciality()

    @PutMapping("/profiles/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateProfile(@PathVariable(value = "id") id: UUID, @Valid @RequestBody updateProfile: Profile.Json): ResponseEntity<Json.Status> {
        var status = Json.Status()
        status.status = 0

        var profile = profileRepository.findByIdAndDeletedAtIsNull(id)
        if (profile.isPresent) {
            if(updateProfile.firstName !== null) profile.get().setFirstName(updateProfile.firstName)
            if(updateProfile.lastName !== null) profile.get().setLastName(updateProfile.lastName)
            if(updateProfile.middleName !== null) profile.get().setMiddleName(updateProfile.middleName)
            if(updateProfile.birthday !== null) profile.get().setBirthday(updateProfile.birthday)
            if(updateProfile.gender !== null) profile.get().setGender(updateProfile.gender)
            if(updateProfile.grants !== null) profile.get().setGrants(updateProfile.grants)
            if(updateProfile.phone !== null) profile.get().setPhone(updateProfile.phone)
            if(updateProfile.skills !== null) profile.get().setSkills(updateProfile.skills)
            if(updateProfile.address !== null) profile.get().setAddress(updateProfile.address)
            if(updateProfile.social !== null) profile.get().setSocial(updateProfile.social)
            if(updateProfile.avatar !== null) profile.get().setAvatar(updateProfile.avatar)
            if(updateProfile.description !== null) profile.get().setDescription(updateProfile.description)
            if(updateProfile.english_type !== null) profile.get().setEnglishType(updateProfile.english_type)
            if(updateProfile.english_value !== null) profile.get().setEnglishValue(updateProfile.english_value)
            if(updateProfile.username !== null) profile.get().setUsername(updateProfile.username)
            if(updateProfile.email !== null) profile.get().setEmail(updateProfile.email)
            if(updateProfile.enabled !== null) profile.get().setEnabled(updateProfile.enabled)

            if (updateProfile.password != null && updateProfile.password!!.length > 0) {
                profile.get().setPassword(encoder.encode(updateProfile.password))
            }
            profileRepository.save(profile.get())

            if (profile.get().getId() !== null) {
                usersRoleRepository.deleteByUserId(profile.get().getId()!!)
                for (item in updateProfile.roles!!) {
                    var _usersRole = UsersRoles(
                            0,
                            profile.get().getId(),
                            item.id,
                            null
                    )
                    usersRoleRepository.save(_usersRole)
                }
            }
            var _edu_ids: ArrayList<UUID> = arrayListOf()
            status.value = updateProfile.education!!
            for (item in updateProfile.education!!) {
                var item_id: UUID? = null
                if (item.id != null) {
                    item_id = item.id
                }
                status.value = item
                val _education = Education(
                        item_id,
                        profile.get().getId(),
                        item.yearStart,
                        item.yearEnd,
                        item.gpa,
                        item.speciality,
                        item.course,
                        item.eduType!!.id,
                        item.eduStatus!!.id
                )
                educationRepository.save(_education)
                if (_education.getId() !== null) {
                    _edu_ids.add(_education.getId()!!)
                }
            }
            if (_edu_ids.size > 0) {
                educationRepository.deleteByProfileIdAndIdNotIn(profile.get().getId()!!, _edu_ids)
            } else {
                educationRepository.deleteByProfileId(profile.get().getId()!!)
            }

            var _exp_ids: ArrayList<UUID> = arrayListOf()
            for (item in updateProfile.experience!!) {
                var item_id: UUID? = null
                if (item.getId() != null) {
                    item_id = item.getId()
                }
                val _experience = Experience(
                        item_id,
                        profile.get().getId(),
                        item.getTitle(),
                        item.getSpeciality(),
                        item.getYearStart(),
                        item.getYearEnd()
                )
                experienceRepository.save(_experience)
                if (_experience.getId() !== null) {
                    _exp_ids.add(_experience.getId()!!)
                }
            }
            if (_exp_ids.size > 0) {
                experienceRepository.deleteByProfileIdAndIdNotIn(profile.get().getId()!!, _exp_ids)
            } else {
                experienceRepository.deleteByProfileId(profile.get().getId()!!)
            }
            status.value = _edu_ids.toString()
            return ResponseEntity(status, HttpStatus.OK)
        }
        status.message = "User registered successfully!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/profiles/new")
    @PreAuthorize("hasRole('ADMIN')")
    fun createProfile(@Valid @RequestBody updateProfile: Profile.Json): ResponseEntity<*> {
        val userCandidate: Optional <Profile> = profileRepository.findByUsernameOrEmailAndDeletedAtIsNull(updateProfile.username!!, updateProfile.email!!)
        var user_id: UUID? = null

        if (userCandidate.isPresent) {
            return ResponseEntity(ResponseMessage("User already exists!"),
                    HttpStatus.BAD_REQUEST)
        }

        val _profile = Profile(
                null,
                updateProfile.firstName,
                updateProfile.lastName,
                updateProfile.middleName,
                updateProfile.birthday,
                updateProfile.gender,
                updateProfile.grants,
                updateProfile.phone,
                updateProfile.skills,
                updateProfile.address,
                updateProfile.social,
                updateProfile.avatar,
                updateProfile.description,
                updateProfile.english_type,
                updateProfile.english_value,
                updateProfile.username,
                updateProfile.email,
                encoder.encode(updateProfile.password),
                updateProfile.enabled,
        false
        )
        profileRepository.save(_profile)
        if (_profile.getId() == null) {
            return ResponseEntity(ResponseMessage("Profile didn't create"),
                    HttpStatus.BAD_REQUEST)
        }

        for (item in updateProfile.roles!!) {
            var _usersRole = UsersRoles(
                    0,
                    _profile.getId(),
                    item.id,
                    null
            )
            usersRoleRepository.save(_usersRole)
        }

        for (item in updateProfile.education!!) {
            val _education = Education(
                    null,
                    _profile.getId(),
                    item.yearStart,
                    item.yearEnd,
                    item.gpa,
                    item.speciality,
                    item.course,
                    item.eduType!!.id,
                    item.eduStatus!!.id
            )
            educationRepository.save(_education)
        }

        for (item in updateProfile.experience!!) {
            val _experience = Experience(
                    null,
                    _profile.getId(),
                    item.getTitle(),
                    item.getSpeciality(),
                    item.getYearStart(),
                    item.getYearEnd()
            )
            experienceRepository.save(_experience)
        }

        return ResponseEntity(ResponseMessage(updateProfile.education.toString()), HttpStatus.OK)
    }

    @PostMapping("/profiles/pp")
    fun postList(): ResponseEntity<*>  {

            var _eduTypeNew = EduType(
                    null,
                    "Test",
                    "",
                    1
            )

            eduTypeRepository.save(_eduTypeNew)
            if (_eduTypeNew.getId() !== null) {
                return ResponseEntity(ResponseMessage("good "), HttpStatus.OK)
            } else {
                return ResponseEntity(ResponseMessage("not "), HttpStatus.BAD_GATEWAY)
            }
    }

    @PostMapping("/profiles/list/csv")
    @PreAuthorize("hasRole('ADMIN')")
    fun getListCsv(@Valid @RequestBody updateProfile: ArrayList<Profile.Json>): ResponseEntity<*> {
        var check: Int = 0
        for (profile in updateProfile) {
            var _email = profile.email!!.toLowerCase()
            if (profile.email!!.trim() == "" || profile.email!!.trim() === null || profile.email!!.indexOf("@") < 0) {
                _email = profile.firstName!!.toLowerCase().trim() + "." + profile.lastName!!.toLowerCase().trim() + "@mdsp.kz"
                continue
//                profile.email = ""
            }
            var username: String = _email.substring(0, _email.indexOf("@"))

            val userCandidate: Optional<Profile> = profileRepository.findByUsernameOrEmailAndDeletedAtIsNull(username.toLowerCase().trim(), _email)
            var user_id: UUID? = null
            var edu_id: UUID? = null
            var edu_type: Long = 1

            if (userCandidate.isPresent) {
                var _roleUser = usersRoleRepository.findByUserId(userCandidate.get().getId()!!)
                if (_roleUser.size == 0) {
                    val _studentRole = roleRepository.findByName("ROLE_STUDENT")
                    if (_studentRole.isPresent) {
                        val _usersRoles = UsersRoles(
                                0,
                                userCandidate.get().getId()!!,
                                _studentRole.get().id,
                                null
                        )
                        usersRoleRepository.save(_usersRoles)
                        check++
                    }
                }
                continue
            }

            var _gender = 1
            var _grants = false

            if (profile.genderString!!.toLowerCase() == "ер" || profile.genderString!!.toLowerCase() == "ұл"  || profile.genderString == null) {
                _gender = 1
            } else {
                _gender = 2
            }

            if (profile.grants) {
                _grants = true
            } else {
                _grants = false
            }

            if (profile.phone !== null && profile.phone!!.length > 0 && profile.phone!![0] == '8') {
                profile.phone = "+7" + profile.phone!!.substring(1);
            }


            val _profile = Profile(
                    null,
                    profile.firstName[0].toUpperCase() + profile.firstName.substring(1).toLowerCase().trim(),
                    profile.lastName[0].toUpperCase() + profile.lastName.substring(1).toLowerCase().trim(),
                    profile.middleName,
                    profile.birthday,
                    _gender,
                    _grants,
                    profile.phone,
                    profile.skills,
                    profile.address,
                    profile.social,
                    profile.avatar,
                    profile.description,
                    1,
                    profile.english_value,
                    username,
                    _email,
                    encoder.encode("123Qwe!"),
                    true,
                    false
            )
            profileRepository.save(_profile)
            if (_profile.getId() == null) {
                return ResponseEntity(ResponseMessage("Profile didn't create"),
                        HttpStatus.BAD_REQUEST)
            }
            val _studentRole = roleRepository.findByName("ROLE_STUDENT")
            if (_studentRole.isPresent) {
                val _usersRoles = UsersRoles(
                        0,
                        _profile.getId(),
                        _studentRole.get().id,
                        null
                )
                usersRoleRepository.save(_usersRoles)
            }

            if (profile.educationStr != null) {
                val _eduType: Optional <EduType> = eduTypeRepository.findFirstByTitleLikeAndTitleIsNotNullAndDeletedAtIsNull("%" + profile.educationStr!!.toString() + "%")

                if (_eduType.isEmpty) {
                    var _eduTypeNew = EduType(
                            null,
                            profile.educationStr!!.toString(),
                            "",
                            1
                    )
                    eduTypeRepository.save(_eduTypeNew)
                    edu_id = _eduTypeNew.getId()
                } else {
                    edu_id = _eduType.get().getId()
                    edu_type = _eduType.get().getStatusId()
                }
            }

            var _course = 1;
            if (profile.course === null || profile.course!! == "") {
                _course = 1;
            } else {
                _course = profile.course!!.toInt()
            }

            val _education = Education(
                    null,
                    _profile.getId(),
                    Date(),
                    Date(),
                    2.0f,
                    profile.speciality!!,
                    _course,
                    edu_id,
                    edu_type
            )
            educationRepository.save(_education)

            if (_education.getId() != null) {
                check++
            }
        }
        return ResponseEntity(ResponseMessage("done " + check.toString()), HttpStatus.OK)
    }

    @PostMapping("/profiles/list/csv/file")
    @PreAuthorize("hasRole('ADMIN')")
    fun postFile(@RequestParam("file") file: MultipartFile): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""
        return ResponseEntity(status, HttpStatus.OK)
    }

    @DeleteMapping("/profiles/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deleteProfile(@PathVariable(value = "id") id: UUID): ResponseEntity<ResponseMessage> {
        var profile = profileRepository.findByIdAndDeletedAtIsNull(id)
        if (profile.isPresent()) {
            profileRepository.deletedAt(id)

            usersRoleRepository.deletedAtByUserId(id)

            educationRepository.deletedAtByProfileId(id)

            experienceRepository.deletedAtByProfileId(id)

            return ResponseEntity(ResponseMessage("Deleted by date"), HttpStatus.OK)
        }
        return ResponseEntity(ResponseMessage("User registered successfully!"), HttpStatus.OK)
    }

    @DeleteMapping("/profiles/return/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun returnProfile(@PathVariable(value = "id") id: UUID): ResponseEntity<ResponseMessage> {
        var profile = profileRepository.findById(id)
        if (profile.isPresent()) {
            profileRepository.returnAt(id)

            usersRoleRepository.returnAtByUserId(id)

            educationRepository.returnAtByProfileId(id)

            experienceRepository.returnAtByProfileId(id)

            return ResponseEntity(ResponseMessage("Deleted by date"), HttpStatus.OK)
        }
        return ResponseEntity(ResponseMessage("User registered successfully!"), HttpStatus.OK)
    }

//    @GetMapping("/profiles/update/usertoprofile")
//    @PreAuthorize("hasRole('ADMIN')")
//    @ResponseBody
//    fun updateUserProfile(): ResponseEntity<ResponseMessage> {
//
//        var _profiles = profileOnlyRepository.findAll()
//        for (profile in _profiles) {
//            val _users = userOnlyRepository.findById(profile.userId!!)
//            profile.username = _users[0].username
//            profile.email = _users[0].email
//            profile.password = _users[0].password
//            profile.enabled = _users[0].enabled
//
//            val _roles = usersRoleRepository.findByUserId(profile.userId!!)
//            for (role in _roles) {
//                role.userId = profile.id
//            }
//            usersRoleRepository.saveAll(_roles)
//        }
//        profileOnlyRepository.saveAll(_profiles)
//        return ResponseEntity(ResponseMessage("Updated!"), HttpStatus.OK)
//    }

//    @GetMapping("/students/update/edu")
//    @PreAuthorize("hasRole('ADMIN')")
//    @ResponseBody
//    fun updateStudentYear(): ResponseEntity<ResponseMessage> {
//
//        var _educations = educationRepository.findAll()
//        for (edu in _educations) {
//            val year_start: Date = Date((Year.now().getValue() - edu.course - 1900), 8,1)
//            val year_end: Date = Date((Year.now().getValue() + (4 - edu.course + 1 - 1900)), 6, 1)
//            edu.yearStart = year_start
//            edu.yearEnd = year_end
//        }
//        educationRepository.saveAll(_educations)//Date((Year.now().getValue() - 1), 8,1).toString()
//        return ResponseEntity(ResponseMessage(Date((Year.now().getValue().toInt() - 1 - 1900), 8,1).toString()), HttpStatus.OK)
//    }


    @PostMapping("/create/super/admin")
    fun registerUser(@Valid @RequestBody password: String): ResponseEntity<*> {
        if (password != "Nursulu") {
            return ResponseEntity(ResponseMessage("Password Wrong"),
                    HttpStatus.BAD_REQUEST)
        }
        if (roleRepository.findByName("ROLE_STUDENT").isEmpty) {
            val role = Role()
            role.name = "ROLE_STUDENT"
            roleRepository.save(role)
        }

        if (roleRepository.findByName("ROLE_ADMIN").isEmpty) {
            val role = Role()
            role.name = "ROLE_ADMIN"
            roleRepository.save(role)
        }

        val eduDegrees: ArrayList<String> = arrayListOf("Бакалавр", "Магистратура", "Докторантура")
        var i: Long = 1
        for (edu in eduDegrees) {
            if (eduDegreeRepository.findByTitle(edu).isEmpty) {
                var eduD = EduDegree(i, edu, i.toInt())
                eduDegreeRepository.save(eduD)
                i++
            }
        }

        i = 1
        val eduStatuses: ArrayList<String> = arrayListOf("Университет", "Академия", "Колледж")
        for (edu in eduStatuses) {
            if (eduStatusRepository.findByTitle(edu).isEmpty) {
                var eduS = EduStatus(i, edu)
                eduStatusRepository.save(eduS)
                i++
            }
        }

        if (!profileRepository.existsByUsername("mdsg_sa")) {
            val userCandidate = Profile()
            userCandidate.setUsername("mdsg_sa")
            userCandidate.setPassword(encoder.encode("Adai07@"))
            userCandidate.setEmail("bsk@mdsp.kz")
            userCandidate.setFirstName("Super")
            userCandidate.setLastName("Admin")
            userCandidate.setEnabled(true)
            userCandidate!!.setRoles(Arrays.asList(roleRepository.findByName("ROLE_ADMIN").get()))

            profileRepository.save(userCandidate)

            return ResponseEntity(ResponseMessage("User registered successfully!"), HttpStatus.OK)
        } else {
            return ResponseEntity(ResponseMessage("User already exists!"),
                    HttpStatus.BAD_REQUEST)
        }
    }

    @GetMapping("/path/update")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateStudentYear(): ResponseEntity<ResponseMessage> {
        var profiles = profileRepository.findAll()
        var i = 0
        for (item in profiles){
            item.setPath("00000000-0000-0000-0000-000000000000," + item.getId())
            profileRepository.save(item)
            i++
        }

        return ResponseEntity(ResponseMessage(i.toString()), HttpStatus.OK)
    }

}
