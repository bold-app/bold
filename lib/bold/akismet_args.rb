  module Bold
  class AkismetArgs

    AKISMET_ENV = %w(
      HTTP_ACCEPT
      HTTP_ACCEPT_CHARSET
      HTTP_ACCEPT_ENCODING
      HTTP_ACCEPT_LANGUAGE
      HTTP_HOST
    )

    def initialize(posting)
      @author_ip = posting.author_ip.to_s

      req = posting.request
      @user_agent = req['user_agent']

      @attribute_hash = {
        created_at: posting.created_at.iso8601,
        env: req.slice(*AKISMET_ENV),
        referrer: req['referrer'],
        test: !Rails.env.production?,
      }.merge(additional_akismet_attributes(posting))
    end

    def to_array
      [ @author_ip, @user_agent, @attribute_hash ]
    end


    private

    def additional_akismet_attributes(posting)
      case posting
      when ContactMessage
        {
          author:       posting.sender_name,
          author_email: posting.sender_email,
          text:         "#{posting.subject}\n#{posting.body}",
          type:         'contact-form',
        }
      when Comment
        {
          author: posting.author_name,
          author_email: posting.author_email,
          author_url: posting.author_website,
          type: 'comment',
          text: posting.body,
          post_url: posting.content.public_url,
          post_modified_at: posting.content.post_date.iso8601,
        }
      else
        {}
      end
    end

  end
end
