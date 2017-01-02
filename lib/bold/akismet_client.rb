require 'akismet/client'

module Bold
  class AkismetClient

    def initialize(site = Bold.current_site)
      @site = site
    end

    def akismet_possible?
      @site.akismet_key.present?
    end

    def run_akismet_check(akismet_args)
      raise 'akismet not configured' unless akismet_possible?

      Akismet::Client.open(*akismet_config) do |client|
        client.check(*akismet_args.to_array)
      end
    end

    def enqueue_akismet_job(method, akismet_args, wait: 1.hour)
      raise 'akismet not configured' unless akismet_possible?

      AkismetUpdateJob.
        set(wait: wait).
        perform_later method.to_s, akismet_config, akismet_args.to_array
    end

    private

    def akismet_config
      [
        @site.akismet_key,
        @site.external_url,
        {
          app_name: Bold.application_name,
          app_version: Bold.version
        }
      ]
    end
  end
end
