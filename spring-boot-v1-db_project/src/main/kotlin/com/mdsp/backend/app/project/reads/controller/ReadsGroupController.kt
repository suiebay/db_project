package com.mdsp.backend.app.project.reads.controller

import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.project.reads.model.ReadsGroup
import com.mdsp.backend.app.project.reads.repository.IReadsGroupRepository
import com.mdsp.backend.app.system.model.Json
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
@RequestMapping("/api/project/mdsreads/groups")
class ReadsGroupController {
    @Autowired
    lateinit var readsGroupRepository: IReadsGroupRepository

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    fun getReadsGroups() = readsGroupRepository.findAllByDeletedAtIsNullOrderByTitle()

    @GetMapping("/get/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getReadsGroup(@PathVariable(value = "id") id: UUID) = readsGroupRepository.findByIdAndDeletedAtIsNull(id)

    @GetMapping("/mentor/check/{id}")
    @PreAuthorize("isAuthenticated()")
    fun getCanCheck(@PathVariable(value = "id") id: UUID, authentication: Authentication): ResponseEntity<*> {
        val userCandidate = profileRepository.findByUsernameAndDeletedAtIsNull(authentication.name)
        if(userCandidate.isPresent) {
            val groupCandidate = readsGroupRepository.findByMentorIdAndDeletedAtIsNull(userCandidate.get().getId()!!)
            if(groupCandidate.isPresent) {
                val profilesCandidate = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNullOrderByReadsPointDescReadsFinishedBooksDesc(groupCandidate.get().getId()!!)
                if(profilesCandidate.isNotEmpty()) {
                    val studentCandidate = profileRepository.findByIdAndDeletedAtIsNull(id)
                    if(studentCandidate.isPresent && profilesCandidate.contains(studentCandidate.get())) {
                        return ResponseEntity(1, HttpStatus.OK)
                    } else {
                        return ResponseEntity("Can't Check", HttpStatus.BAD_REQUEST)
                    }
                 } else {
                    return ResponseEntity("Empty Group", HttpStatus.BAD_REQUEST)
                }
            } else {
                return ResponseEntity("Group doesn't exist", HttpStatus.BAD_REQUEST)
            }
        }
        return ResponseEntity(0, HttpStatus.BAD_REQUEST)
    }

    @PostMapping("/new")
    @PreAuthorize("hasRole('ADMIN')")
    fun createReadsGroup(@Valid @RequestBody newReadsGroup: ReadsGroup.Json): ResponseEntity<*> {
        val status = Json.Status()
        status.status = 0
        status.message = ""

        val readsGroupCandidate: Optional<ReadsGroup> = readsGroupRepository.findByTitleAndDeletedAtIsNull(newReadsGroup.title!!)

        if(!readsGroupCandidate.isPresent) {
            val _readsGroup = ReadsGroup(
                    null,
                    newReadsGroup.title
            )
            readsGroupRepository.save(_readsGroup)
        } else {
            status.status = 0
            status.message = "Group name already exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "New Group created!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/update")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateReadsGroup(@Valid @RequestBody newReadsGroup: ReadsGroup.Json): ResponseEntity<*> {
        val status = Json.Status()
        status.status = 0
        status.message = ""

        val readsGroupCandidate: Optional<ReadsGroup> = readsGroupRepository.findByIdAndDeletedAtIsNull(newReadsGroup.id!!)
        val readsGroupCandidateTitle: Optional<ReadsGroup> = readsGroupRepository.findByTitleAndDeletedAtIsNull(newReadsGroup.title!!)
        if (
                readsGroupCandidate.isPresent
                && ((readsGroupCandidateTitle.isPresent
                        && readsGroupCandidateTitle.get().getId() == newReadsGroup.id)
                        || readsGroupCandidateTitle.isEmpty)
        ) {
            if(newReadsGroup.title !== null) readsGroupCandidate.get().setTitle(newReadsGroup.title!!)
            readsGroupCandidate.get().setMentorId(newReadsGroup.mentorId)

            readsGroupCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))
            readsGroupRepository.save(readsGroupCandidate.get())

            val groupsUsers = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNullOrderByReadsPointDescReadsFinishedBooksDesc(newReadsGroup.id!!)
            if(groupsUsers.size > 0) {
                for(user in groupsUsers) {
                    user.setReadsGroupId(null);
                    profileRepository.save(user);
                }
            }

            if(newReadsGroup.profileIds !== null) {
                val profileIds = newReadsGroup.profileIds!!.split(",").map { it.trim() }
                for (id in profileIds) {
                    try {
                        val profile = profileRepository.findByIdAndDeletedAtIsNull(UUID.fromString(id))
                        if (profile.isPresent) {
                            profile.get().setReadsGroupId(readsGroupCandidate.get().getId())
                            profileRepository.save(profile.get())
                        }
                    } catch (e: Exception) {
                        status.value = e
                    }
                }
                status.value = profileIds
            }
        } else {
            status.status = 0
            status.message = "Group does not exist or Title exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Group updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @PostMapping("/updateTitle")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateReadsGroupTitle(@Valid @RequestBody newReadsGroup: ReadsGroup.Json): ResponseEntity<*> {
        val status = Json.Status()
        status.status = 0
        status.message = ""

        val readsGroupCandidate: Optional<ReadsGroup> = readsGroupRepository.findByIdAndDeletedAtIsNull(newReadsGroup.id!!)
        val readsGroupCandidateTitle: Optional<ReadsGroup> = readsGroupRepository.findByTitleAndDeletedAtIsNull(newReadsGroup.title!!)
        if (
                readsGroupCandidate.isPresent
                && ((readsGroupCandidateTitle.isPresent
                        && readsGroupCandidateTitle.get().getId() == newReadsGroup.id)
                        || readsGroupCandidateTitle.isEmpty)
        ) {
            if(newReadsGroup.title !== null) readsGroupCandidate.get().setTitle(newReadsGroup.title!!)

            readsGroupCandidate.get().setUpdatedAt(Timestamp(System.currentTimeMillis()))
            readsGroupRepository.save(readsGroupCandidate.get())
        } else {
            status.status = 0
            status.message = "Group does not exist or Title exists!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Group updated!"
        return ResponseEntity(status, HttpStatus.OK)
    }

    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deleteReadsGroup(@PathVariable(value = "id") id: UUID): ResponseEntity<*> {
        val status = Json.Status()
        status.status = 0
        status.message = ""

        val readsGroupCandidate: Optional<ReadsGroup> = readsGroupRepository.findByIdAndDeletedAtIsNull(id)

        if(readsGroupCandidate.isPresent) {
            var profileCandidate = profileRepository.findAllByReadsGroupIdAndDeletedAtIsNullOrderByReadsPointDescReadsFinishedBooksDesc(readsGroupCandidate.get().getId()!!)
            if (profileCandidate.isNotEmpty()) {
                for(user in profileCandidate) {
                    user.setReadsGroupId(null)
                    profileRepository.save(user)
                }
            }

            readsGroupCandidate.get().setDeletedAt(Timestamp(System.currentTimeMillis()))
            readsGroupRepository.save(readsGroupCandidate.get())
        } else {
            status.status = 0
            status.message = "Group does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
        status.status = 1
        status.message = "Group deleted!"
        return ResponseEntity(status, HttpStatus.OK)
    }
}
