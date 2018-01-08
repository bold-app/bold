module Ahoy
  class Event < ActiveRecord::Base
    include Ahoy::Properties

    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user, optional: true

    scope :since, ->(time){ where 'time >= ?', time }
    scope :until, ->(time){ where 'time <= ?', time }
    scope :page_views, ->(site_id: Site.current.id, content_id: nil){
      scoped = joins(:visit).where(name: '$view', visits: { site_id: site_id })
      scoped = scoped.where("properties @> '{ \"page\": \"#{content_id}\" }'") if content_id
      scoped
    }

  end
end
