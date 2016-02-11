class ApplicationMailer < ActionMailer::Base
  def self.default_url_options
    { host: Bold::Config['backend_host'], protocol: 'https', only_path: false }
  end

  default from:     Bold::Config['mail_default_from'],
          reply_to: Bold::Config['mail_default_from']

  layout 'mailer'

end
