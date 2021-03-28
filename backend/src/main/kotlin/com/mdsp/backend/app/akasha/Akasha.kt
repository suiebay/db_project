package com.mdsp.backend.app.akasha

import com.mdsp.backend.app.profile.repository.IProfileRepository
import com.mdsp.backend.app.project.reads.repository.IUserBookRepository
import com.mdsp.backend.app.system.model.Json
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.web.bind.annotation.*
import java.util.*


@CrossOrigin(origins = ["https://space.mdsp.kz", "http://localhost:4200"], maxAge = 3600)
@RestController
@RequestMapping("/api/akasha")

class Akasha {
    @Autowired
    lateinit var userBookRepository: IUserBookRepository

    @Autowired
    lateinit var profileRepository: IProfileRepository

    @Scheduled(cron = "0 1 1 * * ?")
//    @GetMapping("/check/reads-point")
    fun checkPoints(): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = ""

        val pointsMap = mutableMapOf<UUID, Int>()
        val userBookCandidate = userBookRepository.findAllByDeletedAtIsNull()
        val changedData: MutableList<Int> = ArrayList()

        if(userBookCandidate.isNotEmpty()) {
            for (i in userBookCandidate) {
                if(pointsMap[i.getProfileId()!!] == null) {
                    pointsMap[i.getProfileId()!!] = 0
                }
                if(i.getGotPoint()!! > 100) {
                    i.setGotPoint(100)
                    userBookRepository.save(i)
                }
                if(i.getGotPoint()!! < -200) {
                    i.setGotPoint(-200)
                    userBookRepository.save(i)
                }
                if(pointsMap[i.getProfileId()!!] != null) {
                    pointsMap[i.getProfileId()!!] = pointsMap[i.getProfileId()!!]!! + i.getGotPoint()!!
                }
            }
            for((key, value) in pointsMap) {
                var profileCandidate = profileRepository.findByIdAndDeletedAtIsNull(key)
                if(profileCandidate.isPresent) {
                    if(profileCandidate.get().getReadsPoint() != value) {
                        profileCandidate.get().setReadsPoint(value)
                        profileRepository.save(profileCandidate.get())
                    }
                }
//                else {
//                    status.status = 0
//                    status.message = "Profile does not exist!"
//                    return ResponseEntity(status, HttpStatus.BAD_REQUEST)
//                }
            }
            return ResponseEntity(changedData, HttpStatus.OK)
        } else {
            status.status = 0
            status.message = "UserBook does not exist!"
            return ResponseEntity(status, HttpStatus.BAD_REQUEST)
        }
    }
}
