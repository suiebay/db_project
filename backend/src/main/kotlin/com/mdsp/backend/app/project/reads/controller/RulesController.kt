package com.mdsp.backend.app.project.reads.controller

import com.mdsp.backend.app.project.reads.model.Rules
import com.mdsp.backend.app.project.reads.repository.IRulesRepository
import com.mdsp.backend.app.system.model.Json
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.sql.Timestamp
import java.util.*
import javax.validation.Valid


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/project/mdsreads/rules")
class RulesController {
    @Autowired
    lateinit var rulesRepository: IRulesRepository

    @GetMapping("/list")
    //@PreAuthorize("isAuthenticated()")
    fun getRules() = rulesRepository.findAllByDeletedAtIsNull()

    @GetMapping("/get/{id}")
    //@PreAuthorize("isAuthenticated()")
    fun getRule(@PathVariable(value = "id") id: UUID) = rulesRepository.findByIdAndDeletedAtIsNull(id)

    @PostMapping("/new")
    //@PreAuthorize("hasRole('ADMIN')")
    fun createRules(@Valid @RequestBody newRules: Rules.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val rulesCandidate: Optional<Rules> = rulesRepository.findByTitleAndDeletedAtIsNull(newRules.title!!)

        if(!rulesCandidate.isPresent) {
            val _rules = Rules(
                    null,
                    newRules.title,
                    newRules.description
            )
            rulesRepository.save(_rules)
        } else {
            status.status = 0
            status.message = "Rule name already exists!"
            return ResponseEntity(status,
                    HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "New Rule created!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/update")
    //@PreAuthorize("hasRole('ADMIN')")
    fun updateRules(@Valid @RequestBody newRules: Rules.Json): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val rulesCandidate: Optional<Rules> = rulesRepository.findByIdAndDeletedAtIsNull(newRules.id!!)
        val rulesCandidateTitle: Optional<Rules> = rulesRepository.findByTitleAndDeletedAtIsNull(newRules.title!!)
        if (
                rulesCandidate.isPresent
                && ((rulesCandidateTitle.isPresent
                        && rulesCandidateTitle.get().getId() == newRules.id)
                        || rulesCandidateTitle.isEmpty)
        ) {
            if(newRules.title !== null) rulesCandidate.get().setTitle(newRules.title!!)
            if(newRules.description !== null) rulesCandidate.get().setDescription(newRules.description!!)

            rulesCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))

            rulesRepository.save(rulesCandidate.get())
        } else {
            status.status = 0
            status.message = "Rule does not exist or Title exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Rule updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @DeleteMapping("/delete/{id}")
    //@PreAuthorize("hasRole('ADMIN')")
    fun deleteRules(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val rulesCandidate: Optional<Rules> = rulesRepository.findByIdAndDeletedAtIsNull(id)

        if(rulesCandidate.isPresent) {
            rulesCandidate.get().setDeletedAt(Timestamp(System.currentTimeMillis()))
            rulesRepository.save(rulesCandidate.get())
        } else {
            status.status = 0
            status.message = "Rule does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Rule deleted!"
        return ResponseEntity(status, HttpStatus.OK)
    }
}
