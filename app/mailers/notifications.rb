class Notifications < ApplicationMailer
  def contact_form_received(contact_message)
    @contact_message = contact_message
    @site = contact_message.site
    subject = "[#{contact_message.site.name}] #{contact_message.subject}"
    mail to: contact_message.receiver_email,
      subject: subject,
      reply_to: contact_message.sender_email
  end

  def comment_received(comment)
    @comment = comment
    @site = comment.site

    subject = "[#{@site.name}] #{comment.subject}"
    mail to: contact_message.receiver_email,
      subject: subject,
      reply_to: contact_message.sender_email
  end
end
