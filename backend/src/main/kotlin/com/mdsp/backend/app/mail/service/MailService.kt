package com.mdsp.backend.app.mail.service


import com.mdsp.backend.app.mail.model.Mail
import freemarker.template.Configuration
import freemarker.template.Template
import freemarker.template.TemplateException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.PropertySource
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.mail.javamail.MimeMessageHelper
import org.springframework.stereotype.Service
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.util.concurrent.TimeUnit
import javax.mail.MessagingException
import javax.mail.internet.MimeMessage

@Service
@PropertySource("classpath:mail.properties")
class MailService {
    private lateinit var mailSender: JavaMailSender

    private var templateConfiguration: Configuration = Configuration()

//    @Value("\${app.velocity.templates.location}")
//    private lateinit var basePackagePath: String
//
//    @Value("\${spring.mail.username}")
//    private lateinit var mailFrom: String
//
//    @Value("\${app.token.password.reset.duration}")
//    private var expiration: Long = 0

    var basePackagePath: String = "/templates/"
    var mailFrom: String = "noreply@mdsp.kz"
    var expiration: Long = 3600000

    @Autowired
    constructor(mailSender: JavaMailSender, templateConfiguration: Configuration) {
        this.mailSender = mailSender
        this.templateConfiguration = templateConfiguration
    }

    constructor() {}

    @Throws(IOException::class, TemplateException::class, MessagingException::class)
    fun sendEmailVerification(emailVerificationUrl: String, to: String) {
        val mail = Mail()
        mail.setSubject("Email Verification [Team CEP]")
        mail.setTo(to)
        mail.setFrom(mailFrom)
        mail.getModel().put("userName", to)
        mail.getModel().put("userEmailTokenVerificationLink", emailVerificationUrl)
        templateConfiguration!!.setClassForTemplateLoading(javaClass, basePackagePath)
        val template: Template = templateConfiguration!!.getTemplate("email-verification.ftl")
        val mailContent: String = FreeMarkerTemplateUtils.processTemplateIntoString(template, mail.getModel())
        mail.setContent(mailContent)
        send(mail)
    }

    /**
     * Setting the mail parameters.Send the reset link to the respective user's mail
     */
    @Throws(IOException::class, TemplateException::class, MessagingException::class)
    fun sendResetLink(resetPasswordLink: String, to: String) {
        val expirationInMinutes = TimeUnit.MILLISECONDS.toMinutes(expiration!!)
        val expirationInMinutesString = expirationInMinutes.toString()
        val mail = Mail()
        mail.setSubject("Password Reset Link [Team CEP]")
        mail.setTo(to)
        mail.setFrom(mailFrom!!)
        mail.getModel().put("userName", to)
        mail.getModel().put("userResetPasswordLink", resetPasswordLink)
        mail.getModel().put("expirationTime", expirationInMinutesString)
        templateConfiguration!!.setClassForTemplateLoading(javaClass, basePackagePath)
        val template: Template = templateConfiguration!!.getTemplate("reset-link.ftl")
        val mailContent: String = FreeMarkerTemplateUtils.processTemplateIntoString(template, mail.getModel())
        mail.setContent(mailContent)
        send(mail)
    }

    /**
     * Send an email to the user indicating an account change event with the correct
     * status
     */
    @Throws(IOException::class, TemplateException::class, MessagingException::class)
    fun sendAccountChangeEmail(action: String?, actionStatus: String?, to: String?) {
        val mail = Mail()
        mail.setSubject("Account Status Change [Team CEP]")
        mail.setTo(to)
        mail.setFrom(mailFrom!!)
        mail.getModel().put("userName", to!!)
        mail.getModel().put("action", action!!)
        mail.getModel().put("actionStatus", actionStatus!!)
        templateConfiguration!!.setClassForTemplateLoading(javaClass, basePackagePath)
        val template: Template = templateConfiguration!!.getTemplate("account-activity-change.ftl")
        val mailContent: String = FreeMarkerTemplateUtils.processTemplateIntoString(template, mail.getModel())
        mail.setContent(mailContent)
        send(mail)
    }

    /**
     * Sends a simple mail as a MIME Multipart message
     */
    @Throws(MessagingException::class)
    fun send(mail: Mail) {
        val message: MimeMessage = mailSender.createMimeMessage()
        val helper = MimeMessageHelper(message, MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED,
                StandardCharsets.UTF_8.name())
        helper.setTo(mail.getTo()!!)
        helper.setText(mail.getContent()!!, true)
        helper.setSubject(mail.getSubject()!!)
        helper.setFrom(mail.getFrom()!!)
        mailSender.send(message)
    }
}
