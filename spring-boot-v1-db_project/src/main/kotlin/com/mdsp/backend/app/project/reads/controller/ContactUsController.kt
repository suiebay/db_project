package com.mdsp.backend.app.project.reads.controller

import com.mdsp.backend.app.project.reads.model.ContactUs
import com.mdsp.backend.app.project.reads.repository.IContactUsRepository
import com.mdsp.backend.app.system.model.Json
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.*
import javax.validation.Valid

@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/project/mdsreads/contactus")
class ContactUsController {
    @Autowired
    lateinit var contactUsRepository: IContactUsRepository

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    fun getContactUsList() = contactUsRepository.findAllByDeletedAtIsNull()

    @GetMapping("/get/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getContactUs(@PathVariable(value = "id") id: UUID) = contactUsRepository.findByIdAndDeletedAtIsNull(id)

    @PostMapping("/new")
    @PreAuthorize("isAuthenticated()")
    fun createContactUs(@Valid @RequestBody newContactUs: ContactUs.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val contactUsCandidate: Optional<ContactUs> = contactUsRepository.findByDescriptionAndDeletedAtIsNull(newContactUs.description!!)

        if(!contactUsCandidate.isPresent) {
            val _contactUs = ContactUs(
                    null,
                    newContactUs.description,
                    newContactUs.userId
            )
            contactUsRepository.save(_contactUs)
        } else {
            status.status = 0
            status.message = "Contact Us description already exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "New Contact Us created!"
        return ResponseEntity(status, HttpStatus.OK)
    }
}
