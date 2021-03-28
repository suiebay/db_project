package com.mdsp.backend.app.profile.service

import com.mdsp.backend.app.profile.model.Profile
import com.mdsp.backend.app.profile.repository.IProfileRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import java.util.*

@Service
class ProfileService {

    @Autowired
    lateinit var profileRepository: IProfileRepository

    fun getProfileById(id: UUID, all: Boolean = false): Optional<Profile> {
        if (all) {
            return profileRepository.findById(id)
        }
        return profileRepository.findByIdAndDeletedAtIsNull(id)
    }

    fun getProfileByUsernameOrEmail(username: String, all: Boolean = false): Optional<Profile> {
        val res = profileRepository.findByUsernameOrEmail(username, username)
        if (all || (res.isPresent && res.get().getDeletedAt() == null)) {
            return res
        }
        return Optional.empty()
    }

    fun getProfileReference(id: UUID): Array<Array<String>>? {
        var _profile = profileRepository.findByIdAndDeletedAtIsNull(id)
        if (_profile.isPresent) {
            var res: Array<Array<String>> = arrayOf()
            res = res.plus(arrayOf(_profile.get().getId().toString()))
            res = res.plus(arrayOf(_profile.get().getFIO()))
            return res
        }
        return null
    }

    /*
     * By Access Token
     */
    fun getProfileReferenceByAT(username: String, all: Boolean = false): Array<Array<String>>? {
        val _profile = this.getProfileByUsernameOrEmail(username, all)
        if (_profile.isPresent) {
            var res: Array<Array<String>> = arrayOf()
            res = res.plus(arrayOf(_profile.get().getId().toString()))
            res = res.plus(arrayOf(_profile.get().getFIO()))
            return res
        }
        return null
    }
}
