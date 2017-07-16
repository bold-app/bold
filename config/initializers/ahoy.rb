Ahoy.mount = false # we mount that manually (frontend routes eat everything otherwise)
Ahoy.geocode = :async

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore

end
