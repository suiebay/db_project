package com.mdsp.backend.app.project.reads.controller

import com.mdsp.backend.app.project.reads.model.Books
import com.mdsp.backend.app.project.reads.repository.IBooksRepository
import com.mdsp.backend.app.project.reads.repository.IUserBookRepository
import com.mdsp.backend.app.system.model.Json
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.sql.Timestamp
import java.util.*
import javax.validation.Valid


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/project/mdsreads/books")
class BooksController {
    @Autowired
    lateinit var booksRepository: IBooksRepository

    @Autowired
    lateinit var userBookRepository: IUserBookRepository

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    fun getBooks() = booksRepository.findAllByDeletedAtIsNull()

    @GetMapping("/list/table")
    @PreAuthorize("isAuthenticated()")
    fun getRefRecordByPage(
        @RequestParam(value = "page") page: Int = 1,
        @RequestParam(value = "size") size: Int = 20
    ): Page<Books> {
        val page: PageRequest = PageRequest.of(page - 1, size)
        return booksRepository.findAllByDeletedAtIsNull(page)
    }

    @GetMapping("/get/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getBook(@PathVariable(value = "id") id: UUID) = booksRepository.findByIdAndDeletedAtIsNull(id)

    @GetMapping("/get-with-deleted/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getBookWithDeleted(@PathVariable(value = "id") id: UUID) = booksRepository.findById(id)

    @GetMapping("/list/sortbytitle")
    @PreAuthorize("isAuthenticated()")
    fun getTitleBooks(): ResponseEntity<*>{
        var booksCandidate = booksRepository.findAllByDeletedAtIsNull()
        booksCandidate.sortBy { it.getTitle() }

        return ResponseEntity(booksCandidate, HttpStatus.OK)
    }

    @GetMapping("/list/{category}/sortbytitle")
    @PreAuthorize("isAuthenticated()")
    fun getBooksByCategory(@PathVariable(value = "category") category: String): ResponseEntity<*>{
        val booksCandidate = if(category == "AdditionalBooks") {
            booksRepository.findAllByCategoryAndDeletedAtIsNull("Additional Books")
        } else {
            booksRepository.findAllByCategoryAndDeletedAtIsNull("$category Grade")
        }

        booksCandidate.sortBy { it.getTitle() }

        return ResponseEntity(booksCandidate, HttpStatus.OK)
    }

    @RequestMapping(value = ["list/search"], method = [RequestMethod.GET])
    @PreAuthorize("isAuthenticated()")
    fun getRatingBooks(@RequestParam("word") word: String): ResponseEntity<*>{

        var booksCandidate = booksRepository.findAllByTitleIgnoreCaseContainsOrAuthorIgnoreCaseContainsAndDeletedAtIsNull(word, word);
        //booksCandidate.sortByDescending { it.getRating() }

        return ResponseEntity(booksCandidate, HttpStatus.OK)
    }

    @PostMapping("/new")
    @PreAuthorize("hasRole('ADMIN')")
    fun createBooks(@Valid @RequestBody newBooks: Books.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val booksCandidate: Optional<Books> = booksRepository.findByTitleAndDeletedAtIsNull(newBooks.title!!)

        if(!booksCandidate.isPresent) {
            val _books = Books(
                    null,
                    newBooks.title,
                    newBooks.author,
                    newBooks.description,
                    newBooks.pageNumber,
                    newBooks.imgStorage,
                    newBooks.category,
                    newBooks.deadline
            )
            booksRepository.save(_books)
        } else {
            status.status = 0
            status.message = "Book name already exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "New Book created!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/update")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateBooks(@Valid @RequestBody newBooks: Books.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val booksCandidate: Optional<Books> = booksRepository.findByIdAndDeletedAtIsNull(newBooks.id!!)
        val booksCandidateTitle: Optional<Books> = booksRepository.findByTitleAndDeletedAtIsNull(newBooks.title!!)
        if (
                booksCandidate.isPresent
                && ((booksCandidateTitle.isPresent
                        && booksCandidateTitle.get().getId() == newBooks.id)
                        || booksCandidateTitle.isEmpty)
        ) {
            if(newBooks.title !== null) booksCandidate.get().setTitle(newBooks.title!!)
            if(newBooks.author !== null) booksCandidate.get().setAuthor(newBooks.author!!)
            if(newBooks.description !== null) booksCandidate.get().setDescription(newBooks.description!!)
            if(newBooks.pageNumber !== null) booksCandidate.get().setPageNumber(newBooks.pageNumber!!)
            if(newBooks.imgStorage !== null) booksCandidate.get().setImgStorage(newBooks.imgStorage!!)
            if(newBooks.category !== null) booksCandidate.get().setCategory(newBooks.category!!)
            if(newBooks.deadline !== null) booksCandidate.get().setDeadline(newBooks.deadline!!)

            booksCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))

            booksRepository.save(booksCandidate.get())
        } else {
            status.status = 0
            status.message = "Books does not exist or Title exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Book updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deleteBooks(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val booksCandidate: Optional<Books> = booksRepository.findByIdAndDeletedAtIsNull(id)

        if(booksCandidate.isPresent) {
            booksCandidate.get().setDeletedAt(Timestamp(System.currentTimeMillis()))
            booksRepository.save(booksCandidate.get())
        } else {
            status.status = 0
            status.message = "Book does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Book deleted!"
        return ResponseEntity(status, HttpStatus.OK)
    }
}
