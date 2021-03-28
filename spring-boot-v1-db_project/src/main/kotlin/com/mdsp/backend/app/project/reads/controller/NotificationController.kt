package com.mdsp.backend.app.project.reads.controller

import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.project.reads.repository.IBooksRepository
import com.mdsp.backend.app.project.reads.repository.IReadsGroupRepository
import com.mdsp.backend.app.project.reads.repository.IUserBookRepository
import com.mdsp.backend.app.system.model.Json
import com.mdsp.backend.app.user.repository.UsersRoleRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import com.mdsp.backend.app.user.model.UsersRoles
import java.sql.Timestamp
import java.util.*
import kotlin.collections.ArrayList


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/project/mdsreads/notification")
class NotificationController {

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Autowired
    lateinit var userBookRepository: IUserBookRepository

    @Autowired
    lateinit var booksRepository: IBooksRepository

    @Autowired
    lateinit var usersRoleRepository: UsersRoleRepository

    @Autowired
    lateinit var groupRepository: IReadsGroupRepository

    @GetMapping("/check")
    @PreAuthorize("isAuthenticated()")
    fun checkNotification(authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        var notificationsList: ArrayList<MutableList<String>> = arrayListOf()

        var userCandidate = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name)

        if(userCandidate.isPresent) {
            var userRoles = usersRoleRepository.findByUserId(userCandidate.get().getId()!!)
            if(userRoles.isNotEmpty()) {
                for (_role in userRoles) {
                    if(_role.roleId.toInt() == 1) {
                        var userBookCandidate = userBookRepository.findAllByProfileIdAndDeletedAtIsNull(userCandidate.get().getId()!!)
                        if(userBookCandidate.isNotEmpty()) {
                            for(_userBookCandidate in userBookCandidate) {
                                var bookCandidate = booksRepository.findByIdAndDeletedAtIsNull(_userBookCandidate.getBookId()!!)
                                if (bookCandidate.isPresent) {
                                    var createdAtUB = _userBookCandidate.getCreatedAt()
                                    if (_userBookCandidate.getVerified() == null
                                            && _userBookCandidate.getCheckRated() == null) {
                                        if (_userBookCandidate.getLastNotification() == null
                                                || _userBookCandidate.getLastNotification()!!.time + 21600000 - System.currentTimeMillis() <= 0) {
                                            if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 0) {
                                                //prosrochen zhiber
                                                notificationsList.add(mutableListOf("MDS Reads", "\"${bookCandidate.get().getTitle()}\" кітабының дедлайны аяқталды! Кітапты бітіріңіз және рецензия жазыңыз!"))
                                            }
                                        }
                                    }
                                    if (_userBookCandidate.getLastNotification() == null
                                            || _userBookCandidate.getLastNotification()!!.time + 21600000 - System.currentTimeMillis() <= 0) {
                                        if (_userBookCandidate.getVerified() == false
                                                && _userBookCandidate.getCheckRated() == true) {
                                            // minus aldyn, birak ali jazgan joksyn
                                            notificationsList.add(mutableListOf("MDS Reads", "Сіз \"${bookCandidate.get().getTitle()}\" кітабының рецензиясын ережеге сай жазбағаныңыз үшін ұпайыңыз шегерілді. Ұпайды қалпына келтіру үшін рецензияны қайта, ережеге сай жазыңыз!"))
                                        }
                                    }
                                    if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 86400000 + 10620000
                                            && createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() >= 86400000 - 10620000) {
                                        //1 kun kaldy zhiber
                                        notificationsList.add(mutableListOf("MDS Reads", "\"${bookCandidate.get().getTitle()}\" кітабының аяқталуына 1 күн қалды! Кітапты аяқтап рецензия жазыңыз"))

                                    }

                                    _userBookCandidate.setLastNotification(Timestamp(System.currentTimeMillis()))
                                    userBookRepository.save(_userBookCandidate)
                                } else {
                                    status.status = 0
                                    status.message = "Book does not exist!"
                                    return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                                }
                            }
                        } else {
                            status.status = 0
                            status.message = "User Book does not exist!"
                            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                        }
                    }
                    var k = 0
                    if(_role.roleId.toInt() == 4) {
                        var groupCandidate = groupRepository.findByMentorIdAndDeletedAtIsNull(userCandidate.get().getId()!!)
                        if(groupCandidate.isPresent) {
                            var studentsCandidate = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNull(groupCandidate.get().getId()!!)
                            if(studentsCandidate.isNotEmpty()) {
                                for(_student in studentsCandidate) {
                                    var userBookCandidate = userBookRepository.findAllByProfileIdAndDeletedAtIsNull(_student.getId()!!)
                                    if(userBookCandidate.isNotEmpty()) {
                                        for(_userBookCandidate in userBookCandidate) {
                                            var bookCandidate = booksRepository.findByIdAndDeletedAtIsNull(_userBookCandidate.getBookId()!!)
                                            if (bookCandidate.isPresent) {
                                                if (_userBookCandidate.getVerified() == null
                                                        && _userBookCandidate.getCheckRated() == null) {
                                                    var createdAtUB = _userBookCandidate.getCreatedAt()
                                                    if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 0) {
                                                        //prosrochen zhiber
                                                        notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} студентіңіздің \"${bookCandidate.get().getTitle()}\" кітабының дедлайны өтіп кетті. Студентіңізге ескертіңіз!"))
                                                    }
                                                }
                                                if (_userBookCandidate.getVerified() == true
                                                        && _userBookCandidate.getCheckRated() == false) {
                                                    // student kitap bitirdi bagala
                                                    notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} студентіңіз \"${bookCandidate.get().getTitle()}\" кітабын аяқтады. Рецензияны тексеріңіз және бағалаңыз!"))
                                                }
//                                                if (_userBookCandidate.getVerified() == false
//                                                        && _userBookCandidate.getCheckRated() == true) {
//                                                    // minus aldy, birak ali jazgan jok
//                                                    notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} got minus point from book \"${bookCandidate.get().getTitle()}\". Please WARN him/her to not cheat and to write a review again himself/herself"))
//                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                status.status = 0
                                status.message = "Group is empty!"
                                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                            }
                        } else {
                            status.status = 0
                            status.message = "Reads Group does not exist!"
                            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                        }
                    }
                }
            } else {
                status.status = 0
                status.message = "User role does not exist!"
                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
            }
        } else {
            status.status = 0
            status.message = "User does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        return ResponseEntity(notificationsList, HttpStatus.OK)
    }

    @GetMapping("/check/{id}")
    fun checkNotificationId(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        var notificationsList: ArrayList<MutableList<String>> = arrayListOf()

        var userCandidate = profileRepository.findByIdAndDeletedAtIsNull(id)

        if(userCandidate.isPresent) {
            var userRoles = usersRoleRepository.findByUserId(userCandidate.get().getId()!!)
            if(userRoles.isNotEmpty()) {
                for (_role in userRoles) {
                    if(_role.roleId.toInt() == 1) {
                        var userBookCandidate = userBookRepository.findAllByProfileIdAndDeletedAtIsNull(userCandidate.get().getId()!!)
                        if(userBookCandidate.isNotEmpty()) {
                            for(_userBookCandidate in userBookCandidate) {
                                var bookCandidate = booksRepository.findByIdAndDeletedAtIsNull(_userBookCandidate.getBookId()!!)
                                if (bookCandidate.isPresent) {
                                    var createdAtUB = _userBookCandidate.getCreatedAt()
                                    if (_userBookCandidate.getVerified() == null
                                            && _userBookCandidate.getCheckRated() == null) {
                                        if (_userBookCandidate.getLastNotification() == null
                                                || _userBookCandidate.getLastNotification()!!.time + 21600000 - System.currentTimeMillis() <= 0) {
                                            if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 0) {
                                                //prosrochen zhiber
                                                notificationsList.add(mutableListOf("MDS Reads", "\"${bookCandidate.get().getTitle()}\" кітабының дедлайны аяқталды! Кітапты бітіріңіз және рецензия жазыңыз!"))
                                            }
                                        }
                                    }
                                    if (_userBookCandidate.getLastNotification() == null
                                            || _userBookCandidate.getLastNotification()!!.time + 21600000 - System.currentTimeMillis() <= 0) {
                                        if (_userBookCandidate.getVerified() == false
                                                && _userBookCandidate.getCheckRated() == true) {
                                            // minus aldyn, birak ali jazgan joksyn
                                            notificationsList.add(mutableListOf("MDS Reads", "Сіз \"${bookCandidate.get().getTitle()}\" кітабының рецензиясын ережеге сай жазбағаныңыз үшін ұпайыңыз шегерілді. Ұпайды қалпына келтіру үшін рецензияны қайта, ережеге сай жазыңыз!"))
                                        }
                                    }
                                    if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 86400000 + 10620000
                                            && createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() >= 86400000 - 10620000) {
                                        //1 kun kaldy zhiber
                                        notificationsList.add(mutableListOf("MDS Reads", "\"${bookCandidate.get().getTitle()}\" кітабының аяқталуына 1 күн қалды! Кітапты аяқтап рецензия жазыңыз"))

                                    }

                                    _userBookCandidate.setLastNotification(Timestamp(System.currentTimeMillis()))
                                    userBookRepository.save(_userBookCandidate)
                                } else {
                                    status.status = 0
                                    status.message = "Book does not exist!"
                                    return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                                }
                            }
                        } else {
                            status.status = 0
                            status.message = "User Book does not exist!"
                            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                        }
                    }
                    var k = 0
                    if(_role.roleId.toInt() == 4) {
                        var groupCandidate = groupRepository.findByMentorIdAndDeletedAtIsNull(userCandidate.get().getId()!!)
                        if(groupCandidate.isPresent) {
                            var studentsCandidate = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNull(groupCandidate.get().getId()!!)
                            if(studentsCandidate.isNotEmpty()) {
                                for(_student in studentsCandidate) {
                                    var userBookCandidate = userBookRepository.findAllByProfileIdAndDeletedAtIsNull(_student.getId()!!)
                                    if(userBookCandidate.isNotEmpty()) {
                                        for(_userBookCandidate in userBookCandidate) {
                                            var bookCandidate = booksRepository.findByIdAndDeletedAtIsNull(_userBookCandidate.getBookId()!!)
                                            if (bookCandidate.isPresent) {
                                                if (_userBookCandidate.getVerified() == null
                                                        && _userBookCandidate.getCheckRated() == null) {
                                                    var createdAtUB = _userBookCandidate.getCreatedAt()
                                                    if (createdAtUB!!.time + (bookCandidate.get().getDeadline()!! * 86400000) - System.currentTimeMillis() <= 0) {
                                                        //prosrochen zhiber
                                                        notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} студентіңіздің \"${bookCandidate.get().getTitle()}\" кітабының дедлайны өтіп кетті. Студентіңізге ескертіңіз!"))
                                                    }
                                                }
                                                if (_userBookCandidate.getVerified() == true
                                                        && _userBookCandidate.getCheckRated() == false) {
                                                    // student kitap bitirdi bagala
                                                    notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} студентіңіз \"${bookCandidate.get().getTitle()}\" кітабын аяқтады. Рецензияны тексеріңіз және бағалаңыз!"))
                                                }
//                                                if (_userBookCandidate.getVerified() == false
//                                                        && _userBookCandidate.getCheckRated() == true) {
//                                                    // minus aldy, birak ali jazgan jok
//                                                    notificationsList.add(mutableListOf("MDS Reads", "${_student.getFirstName()} ${_student.getLastName()} got minus point from book \"${bookCandidate.get().getTitle()}\". Please WARN him/her to not cheat and to write a review again himself/herself"))
//                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                status.status = 0
                                status.message = "Group is empty!"
                                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                            }
                        } else {
                            status.status = 0
                            status.message = "Reads Group does not exist!"
                            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                        }
                    }
                }
            } else {
                status.status = 0
                status.message = "User role does not exist!"
                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
            }
        } else {
            status.status = 0
            status.message = "User does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        return ResponseEntity(notificationsList, HttpStatus.OK)
    }
}
