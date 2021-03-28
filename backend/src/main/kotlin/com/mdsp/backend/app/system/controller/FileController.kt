package com.mdsp.backend.app.system.controller

import com.mdsp.backend.app.system.model.Json
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.util.StringUtils
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.awt.Image
import java.awt.image.BufferedImage
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import java.util.*
import javax.imageio.ImageIO


@RestController
@RequestMapping("/api/file")
class FileController {
    @Value("\${file.upload-dir}")
    private val pathFiles: String? = null

    @Value("\${file.tmp.url}")
    private val urlFiles: String? = null

    @PostMapping("/upload/{type}")
    //@PreAuthorize("isAuthenticated()")
    fun uploadToLocalFileSystem(@RequestParam("file") file: MultipartFile, @PathVariable(value = "type") type: String): ResponseEntity<*> {
        var status = Json.Status()
        status.status = 0
        status.message = "Not access format"
        status.value = null

        val accessFormat: Array<String> = arrayOf("jpg","jpeg","png","webp","bmp","svg")
        val fileName: String = StringUtils.cleanPath(file.originalFilename.toString())

//        val extension = fileName.split(".")[fileName.split(".").size - 1]
        val extension = File(fileName).extension
        if (accessFormat.contains(extension)) {
            val fileNameStr: String = "mds_avatar_" + UUID.randomUUID().toString() + "."
            val path: Path = Paths.get(pathFiles + "/images/${type}/" + fileNameStr + extension)
            var res = urlFiles +"/images/${type}/" + fileNameStr + extension

            var fileN: File
            var secondFile: File
            try {
                Files.copy(file.inputStream, path, StandardCopyOption.REPLACE_EXISTING)

                fileN = File(pathFiles + "/images/${type}/" + fileNameStr + extension)
                val filePNG: String = fileNameStr + "png"
                secondFile = File(pathFiles + "/images/${type}/400x400_" + filePNG)
                if (extension == "webp" || extension == "svg") {
                    status.status = 1
                    status.message = "Successful uploaded"
                    status.value = res
                    return ResponseEntity(status, HttpStatus.OK)
                }
                var rImage: BufferedImage = ImageIO.read(fileN)
                val imWidth = rImage.width;
                val imHeight = rImage.height
                var x = 0
                var y = 0
                var wh = imWidth
                if (imWidth > imHeight) {
                    x = (imWidth - imHeight) / 2
                    wh = imHeight
                } else {
                    y = (imHeight - imWidth) / 2
                }
                rImage = rImage.getSubimage(x, y, wh, wh)

                var resized: BufferedImage? = rImage
                if (resized !== null && resized.width > 700) {
                    resized = resize(rImage, 700, 700)
                    ImageIO.write(resized, "png", secondFile)
                }
                if (secondFile.exists()) {
                    res = urlFiles + "/images/${type}/400x400_" + filePNG
                    fileN.delete()
                } else if (!fileN.exists()) {
                    status.status = -1
                    status.message = "File not saved"
                    return ResponseEntity(status, HttpStatus.OK)
                }


            } catch (e: IOException) {
                e.printStackTrace()
            }
            status.status = 1
            status.message = "Successful uploaded"
            status.value = res
            return ResponseEntity(status, HttpStatus.OK)
        }
        return ResponseEntity(status, HttpStatus.OK)
    }

    private fun resize(img: BufferedImage, height: Int, width: Int): BufferedImage? {
        val tmp = img.getScaledInstance(width, height, Image.SCALE_SMOOTH)
        val resized = BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB)
        val g2d = resized.createGraphics()
        g2d.drawImage(tmp, 0, 0, null)
        g2d.dispose()
        return resized
    }
}
