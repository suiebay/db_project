package com.mdsp.backend.app.project.reads.controller

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import com.mdsp.backend.app.profile.model.Profile
import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.project.reads.model.Rules
import com.mdsp.backend.app.project.reads.model.UserBook
import com.mdsp.backend.app.project.reads.repository.IBooksRepository
import com.mdsp.backend.app.project.reads.repository.IUserBookRepository
import com.mdsp.backend.app.system.model.Json
import com.mdsp.backend.app.user.repository.RoleRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.sql.Timestamp
import java.util.*
import javax.validation.Valid


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/project/mdsreads/userbook")
class UserBookController {
    @Autowired
    lateinit var userBookRepository: IUserBookRepository

    @Autowired
    lateinit var booksRepository: IBooksRepository

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Autowired
    lateinit var roleRepository: RoleRepository

    @GetMapping("/readingslist/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getReadingsList(@PathVariable(value = "id") id: UUID) = userBookRepository.findAllByBookIdAndEndDateIsNullAndDeletedAtIsNull(id)

    @GetMapping("/finishedlist/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getFinishedList(@PathVariable(value = "id") id: UUID) = userBookRepository.findAllByBookIdAndEndDateIsNotNullAndDeletedAtIsNull(id)

    @GetMapping("/userfinishedlist/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getUserFinishedList(@PathVariable(value = "id") id: UUID) = userBookRepository.findAllByProfileIdAndEndDateIsNotNullAndDeletedAtIsNull(id)

    @GetMapping("/userfinishedlist-with-deleted/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getUserFinishedListWithDeleted(@PathVariable(value = "id") id: UUID) = userBookRepository.findAllByProfileIdAndEndDateIsNotNull(id)

    @GetMapping("/get/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getUserBook(@PathVariable(value = "id") id: UUID) = userBookRepository.findByIdAndDeletedAtIsNull(id)

    @GetMapping("/getbyuser/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getReadingUserBook(@PathVariable(value = "id") id: UUID) = userBookRepository.findByProfileIdAndEndDateIsNullAndDeletedAtIsNull(id)

    @GetMapping("/getbyuser-with-deleted/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getReadingUserBookWithDeleted(@PathVariable(value = "id") id: UUID) = userBookRepository.findByProfileIdAndEndDateIsNull(id)

    @PostMapping("/getrepeat")
    @PreAuthorize("isAuthenticated()")
    fun getRepeatUserBook(@Valid @RequestBody repeatUserBook: UserBook.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        var repeatCandidate = userBookRepository.findByProfileIdAndBookIdAndDeletedAtIsNull(repeatUserBook.profileId!!, repeatUserBook.bookId!!)

        if(repeatCandidate.isPresent) {
            status.status = 0
            status.message = "You already read this book"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "You can read this book"
        return ResponseEntity(status, HttpStatus.BAD_REQUEST)
    }

    @PostMapping("/new")
    @PreAuthorize("isAuthenticated()")
    fun createUserBook(@Valid @RequestBody newUserBook: UserBook.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val userBookRepeat = userBookRepository.findByProfileIdAndBookIdAndDeletedAtIsNull(newUserBook.profileId!!, newUserBook.bookId!!);
        if(userBookRepeat.isPresent) {
            status.status = 0
            status.message = "You already read this book"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }

        val userBookCandidate: Optional<UserBook> = userBookRepository.findByProfileIdAndEndDateIsNullAndDeletedAtIsNull(newUserBook.profileId!!)

        if(!userBookCandidate.isPresent) {
            val _userBook = UserBook(
                    null,
                    newUserBook.bookId,
                    newUserBook.profileId,
                    Timestamp(System.currentTimeMillis()),
                    newUserBook.endDate,
                    newUserBook.bookReview,
                    newUserBook.bookRating,
                    newUserBook.gotPoint
            )
            userBookRepository.save(_userBook)
        } else {
            status.status = 0
            status.message = "You already have your reading book"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Book Added!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/finish")
    @PreAuthorize("isAuthenticated()")
    fun finishUserBook(@Valid @RequestBody newUserBook: UserBook.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val userBookCandidate: Optional<UserBook> = userBookRepository.findById(newUserBook.id!!)
        if (userBookCandidate.isPresent && (userBookCandidate.get().getVerified() == false || userBookCandidate.get().getVerified() == null)) {
            if(newUserBook.bookReview!!.split(" ").size < 50) {
                status.status = 0
                status.message = "Review must consist minimum 50 words!"
                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
            }

            var profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(newUserBook.profileId!!)
            if(profileCandidate.isPresent) {
                if(profileCandidate.get().getReadsFinishedBooks() == null) {
                    profileCandidate.get().setReadsFinishedBooks(0);
                }
                if(profileCandidate.get().getReadsReviewNumber() == null) {
                    profileCandidate.get().setReadsReviewNumber(0);
                }
                profileCandidate.get().setReadsFinishedBooks(profileCandidate.get().getReadsFinishedBooks()!! + 1)
                profileCandidate.get().setReadsReviewNumber(profileCandidate.get().getReadsReviewNumber()!! + 1)
                profileRepository.save(profileCandidate.get())

                if (newUserBook.bookReview !== null) userBookCandidate.get().setBookReview(newUserBook.bookReview!!)
                if (newUserBook.bookRating !== null) userBookCandidate.get().setBookRating(newUserBook.bookRating!!)
                userBookCandidate.get().setCheckRated(false)
                userBookCandidate.get().setVerified(true)

                var bookCandidate = booksRepository.findById(newUserBook.bookId!!)
                if (bookCandidate.isPresent) {
                    if (bookCandidate.get().getLeftRatings() == null) {
                        bookCandidate.get().setLeftRatings(0)
                    }
                    bookCandidate.get().setLeftRatings(bookCandidate.get().getLeftRatings()!! + 1)
                    if (bookCandidate.get().getRatingSum() == null) {
                        bookCandidate.get().setRatingSum(0.0)
                    }
                    bookCandidate.get().setRatingSum(bookCandidate.get().getRatingSum()!! + newUserBook.bookRating!!)
                    if (bookCandidate.get().getLeftRatings()!! == 0) {
                        bookCandidate.get().setRating(0.0)
                    } else {
                        bookCandidate.get().setRating(bookCandidate.get().getRatingSum()!! / bookCandidate.get().getLeftRatings()!!)
                    }
                    booksRepository.save(bookCandidate.get())
                } else {
                    status.status = 0
                    status.message = "Book does not exist!"
                    return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                }

                userBookCandidate.get().setEndDate(Timestamp(System.currentTimeMillis()))
                userBookRepository.save(userBookCandidate.get())
            } else {
                status.status = 0
                status.message = "Profile does not exist!"
                return ResponseEntity(status, HttpStatus.BAD_REQUEST)
            }
        } else {
            status.status = 0
            status.message = "UserBook does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Book reviewed!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/recommendation/new")
    @PreAuthorize("isAuthenticated()")
    fun addRecommendationBook(@Valid @RequestBody recommendBook: Profile.ReadsRecommendationJson, authentication: Authentication): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        var books: ArrayList<Profile.ReadsRecommendationJson> = arrayListOf()
        var profileCandidate = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name)

        var mapper: ObjectMapper = ObjectMapper()
        var finalRecommendBook: String? = ""

        var _recommendBook = Profile.ReadsRecommendationJson(
                recommendBook.bookName,
                recommendBook.bookAuthor
        )

        books.add(_recommendBook)

        finalRecommendBook = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(books)

        if(profileCandidate.get().getReadsRecommendation() == null) {
            profileCandidate.get().setReadsRecommendation(finalRecommendBook!!)
            profileRepository.save(profileCandidate.get())

            status.status = 1
            status.message += "books recommendation are updated!"
            return ResponseEntity(status, HttpStatus.OK)
        }

        val recommendations: ArrayList<Profile.ReadsRecommendationJson> = mapper.readValue(profileCandidate.get().getReadsRecommendation()!!)

        recommendations.add(books[0])

        finalRecommendBook = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(recommendations)
        profileCandidate.get().setReadsRecommendation(finalRecommendBook!!)

        profileRepository.save(profileCandidate.get())

        status.status = 1
        status.message += "books recommendation are updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/rate")
    @PreAuthorize("hasRole('READS_MENTOR') or hasRole('ADMIN')")
    fun rateUserBook(@Valid @RequestBody newUserBook: UserBook.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val _adminRole = roleRepository.findByName("ROLE_ADMIN")

        val userBookCandidate: Optional<UserBook> = userBookRepository.findById(newUserBook.id!!)

        if (userBookCandidate.isPresent && _adminRole.isPresent) {
            var profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(newUserBook.profileId!!)

            if(!profileCandidate.get().getRoles()!!.contains(_adminRole.get())) {
                if (newUserBook.bookReview!!.split(" ").size < 50) {
                    status.status = 0
                    status.message = "Review must consist minimum 50 words!"
                    return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                }
            }
            if(newUserBook.adminPoint !== null) {
                userBookCandidate.get().setGotPoint(newUserBook.gotPoint!! + newUserBook.adminPoint!!)
                userBookCandidate.get().setCheckRated(true)
                if(profileCandidate.get().getReadsPoint() == null) {
                    profileCandidate.get().setReadsPoint(0)
                }
                profileCandidate.get().setReadsPoint(profileCandidate.get().getReadsPoint()!! + newUserBook.adminPoint!!)
                profileRepository.save(profileCandidate.get())

                if(newUserBook.adminPoint!! < 0) {
                    userBookCandidate.get().setChanceNumber(userBookCandidate.get().getChanceNumber()!! + 1)

                    if(userBookCandidate.get().getChanceNumber()!! >= 2) {
                        userBookCandidate.get().setVerified(true)
                        //userBookCandidate.get().setBookReview("CHEATED")
                    } else {
                        userBookCandidate.get().setVerified(false)
                        //userBookCandidate.get().setBookReview("YOU ARE CHEATED AND GOT MINUS 15 POINTS, WRITE YOUR REVIEW AGAIN YOURSELF")
                    }
                    var bookCandidate = booksRepository.findById(newUserBook.bookId!!)
                    if(bookCandidate.isPresent) {
                        if (userBookCandidate.get().getBookRating() != 0.0 && userBookCandidate.get().getChanceNumber()!! == 1 && !profileCandidate.get().getRoles()!!.contains(_adminRole.get())) {

                            profileCandidate.get().setReadsFinishedBooks(profileCandidate.get().getReadsFinishedBooks()!! - 1)
                            profileCandidate.get().setReadsReviewNumber(profileCandidate.get().getReadsReviewNumber()!! - 1)
                            profileRepository.save(profileCandidate.get())

                            bookCandidate.get().setLeftRatings(bookCandidate.get().getLeftRatings()!! - 1)
                            bookCandidate.get().setRatingSum(bookCandidate.get().getRatingSum()!! - newUserBook.bookRating!!)
                            if (bookCandidate.get().getLeftRatings()!! == 0) {
                                bookCandidate.get().setRating(0.0)
                            } else {
                                bookCandidate.get().setRating(bookCandidate.get().getRatingSum()!! / bookCandidate.get().getLeftRatings()!!)
                            }
                            userBookCandidate.get().setBookRating(0.0)
                            booksRepository.save(bookCandidate.get())
                        }
                    } else {
                        status.status = 0
                        status.message = "Book does not exist!"
                        return ResponseEntity(status, HttpStatus.BAD_REQUEST)
                    }
                } else {
                    userBookCandidate.get().setVerified(true)
                }
            }
            userBookCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))
            userBookRepository.save(userBookCandidate.get())
        } else {
            status.status = 0
            status.message = "UserBook does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Book reviewed!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deleteUserBook(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val userBookCandidate: Optional<UserBook> = userBookRepository.findByIdAndDeletedAtIsNull(id)

        if(userBookCandidate.isPresent) {
            userBookCandidate.get().setDeletedAt(Timestamp(System.currentTimeMillis()))
            userBookRepository.save(userBookCandidate.get())
        } else {
            status.status = 0
            status.message = "UserBook does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "UserBook deleted!"
        return ResponseEntity(status, HttpStatus.OK)
    }
}
