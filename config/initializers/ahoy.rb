Ahoy.mount = false # we mount that manually (frontend routes eat everything otherwise)
Ahoy.geocode = :async

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def track_visit(options)
    super do |visit|
      visit.site_id = Site.for_hostname(request.host)&.id
    end
  end

end
