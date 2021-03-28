package com.mdsp.backend.app.system.model

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.convertValue
import org.springframework.context.annotation.Configuration
import java.io.File
import java.util.*
import java.util.concurrent.ThreadLocalRandom
import kotlin.collections.ArrayList


@Configuration
class Util {
    companion object {
//        @Value("${mdsp.path.tmp}")
        var sTmp: String = "/Users/bekzat/.bitnami/stackman/machines/xampp/volumes/root/htdocs/tmp.mds/"

        fun createTmpFileMdsp(data: Any, files: String): Boolean {
            val fileName = files + "_mds_education.json"

            var file = File(fileName)

            if (file.exists()) {
                return true
            }

            // create a new file
            val isNewFileCreated: Boolean = file.createNewFile()

            if (isNewFileCreated) {
                println("$fileName is created successfully.")
            } else {
                println("$fileName already exists.")
                return true
            }

            File(fileName).printWriter().use { out ->
                out.println(data)
            }
            return true
        }

        fun getTmpFiles(files: String): Boolean {
            val fileName = files

            var file = File(fileName)

            if (file.exists()) {
                return true
            }
            return false
        }

        fun checkAccess(courseAccess: String, path: String): Boolean {
            var pathList: List<String> = path.split(",").map { it.trim() }
            for (id in pathList) {
                if (courseAccess.contains(id)) {
                    return true
                }
            }
            return false
        }

        fun shuffleVariants(ar: ArrayList<String>) {
            // If running on Java 6 or older, use `new Random()` on RHS here
            val rnd: Random = ThreadLocalRandom.current()
            for (i in ar.size - 1 downTo 1) {
                val index: Int = rnd.nextInt(i + 1)
                // Simple swap
                val a = ar[index]
                ar[index] = ar[i]
                ar[i] = a
            }
        }

        fun generateRandomUuid(): UUID {
            return UUID.randomUUID()
        }

        fun getRandomString(length: Int) : String {
            val charset = ('a'..'z') + ('0'..'9')

            return List(length) { charset.random() }
                .joinToString("")
        }

        fun toArrayMap(json: String?): ArrayList<MutableMap<String, Any?>> {
            var result: ArrayList<MutableMap<String, Any?>> = arrayListOf()
            if (json != null) {
                val mapper = ObjectMapper()
                val jsonE = mapper.readValue(json, ArrayList::class.java)
                return jsonE as ArrayList<MutableMap<String, Any?>>
            }
            return result
        }

        fun toJson(json: String?): MutableMap<String, Any?> {
            var result: MutableMap<String, Any?> = mutableMapOf()
            if (json != null) {
                val mapper = ObjectMapper()
                val jsonE = mapper.readValue(json, MutableMap::class.java).toMutableMap()
                for (item in jsonE) {
                    result[item.key.toString()] = item.value
                }
            }
            return result
        }

        fun toMutableJson(json: String?): MutableMap<String, MutableMap<String, Any?>> {
            var result: MutableMap<String, MutableMap<String, Any?>> = mutableMapOf()
            if (json != null) {
                val mapper = ObjectMapper()
                val jsonE = mapper.readValue(json, MutableMap::class.java).toMutableMap()
                for (item in jsonE) {
                    result[item.key.toString()] = item.value as MutableMap<String, Any?>
                }
            }
            return result
        }

        fun mapToString(value: Array<MutableMap<String, Any?>>?) : String? {
            val mapper = ObjectMapper()
            var result: String? = ""
            if (value != null) {
                var i = 0
                for (item in value!!) {
                    if (i == 0) {
                        result += mapper.writeValueAsString(item)
                    } else {
                        result += "," + mapper.writeValueAsString(item)
                    }
                    i++
                }
                result = "[$result]"
            } else {
                result = null
            }

            return result
        }

        fun mergeMutableMap(map1: MutableMap<String, Any?>, map2: MutableMap<String, Any?>): MutableMap<String, Any?> {
            var result: MutableMap<String, Any?> = mutableMapOf()
            result.putAll(map1)
            result.putAll(map2)
            return result
        }

        fun mutableMapAsString(value: Any?): String {
            val mapper = ObjectMapper()
            return mapper.writeValueAsString(value)
        }

        fun getMutableToArraySerialize(resVal: ArrayList<MutableMap<String, Any?>>): String? {
            var id: Array<String> = arrayOf()
            var value: Array<String> = arrayOf()
            var res: String? = "{}"
            for (item in resVal) {
                id = id.plus(item["id"].toString().trim())
                value = value.plus(item["value"].toString().trim())
            }
            if (id.size == value.size && id.isNotEmpty()) {
                res = "{{\"" + id.joinToString("\",\"") + "\"},{\"" + value.joinToString("\",\"") + "\"}}"
            }
            return res
        }

        fun unserialized(resVal: String): MutableMap<String, Any?> {
            var resSer = setQuotes(resVal)
            val resultJson: MutableMap<String, Any?> = mutableMapOf()
            if (resSer.indexOf("{{") == 0) {
                resSer = resSer
                    .replace("{{", "{ \"0\": [")
                    .replace("},{", "], \"1\": [")
                    .replace("}}", "]}")
                val jsonRes: MutableMap<String, ArrayList<Any?>> = toJson(resSer) as  MutableMap<String, ArrayList<Any?>>
                if (jsonRes["0"] != null && jsonRes["0"]!!.size === jsonRes["1"]!!.size) {
                    val firstRow = jsonRes["0"]!!
                    val secondRow = jsonRes["1"]!!
                    for ((key, item) in firstRow.withIndex()) {
                        resultJson[item.toString()] = secondRow[key]
                    }
                }
            } else {
                //TODO odinarnii bolganda
            }

           return resultJson
        }

        fun setQuotes(value: String): String {
            var res: Array<String> = arrayOf()
            var result = ""
            if (value.indexOf("{{") == 0) {
                var arrValue = value
                    .replace("{{", "")
                    .replace("}}", "")
                    .split("},{")
                for (item in arrValue) {
                    res = res.plus(this.setQuotesString(item))
                }
                result = "{{" + res.joinToString("},{") + "}}"
            } else {
                //TODO odinarnii bolganda
            }
            return result
        }

        private fun setQuotesString(value: String): String {
            val result = value.split(",")
            var res: Array<String> = arrayOf()
            for (item in result) {
                res = if (item == "NULL") {
                    res.plus("null")
                } else if (item.count { "\"".contains(it) } == 0) {
                    res.plus("\"" + item + "\"")
                } else {
                    res.plus(item)
                }
            }
            return res.joinToString(",")
        }

        fun isToday(date1: Date, date2: Date): Boolean {
            return (date1.date == date2.date && date1.month == date2.month && date1.year == date2.year)
        }

        fun objectToJson(objectVal: Any): MutableMap<String, Any?> {
            val objectMapper = ObjectMapper()
            return objectMapper.convertValue(objectVal)
        }
    }
}

