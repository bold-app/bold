class Notifications < ApplicationMailer
  def daily_summary(user, site)
    @site = site
    Bold.with_site(site) do
      postings = site.visitor_postings.alive.recent
      if postings.any?
        @postings = postings.group_by(&:type)
        subject = "[#{site.name}] Daily Activity (#{I18n.l Time.now.to_date}) - #{postings.count}"
        mail to: user.email, subject: subject
      end
    end
  end

end
