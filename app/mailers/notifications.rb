class Notifications < ApplicationMailer

  def unread_items(email_address, site, count)
    @site = site
    @count = count
    @url = bold_site_activity_comments_url(site)

    subject = I18n.t(
      "email.unread_items.subject", site: site.name, count: count
    )
    mail to: email_address, subject: subject
  end

end
