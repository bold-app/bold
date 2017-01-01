# Sends out unread items notifications to users who activated this in their
# preferences.
#
# Run it from a cron job like this:
#
# bin/rails r 'SendUnreadItemsNotifications.call'
#
class SendUnreadItemsNotifications < ApplicationAction

  Result = ImmutableStruct.new(:success?, :notifications_sent)

  def initialize
    @mails_sent = 0
  end

  def self.call
    result = new.call
    if result.success?
      if result.notifications_sent > 0
        puts "sent #{result.notifications_sent} emails"
      end
    else
      puts 'sending unread items notifications failed'
    end
  end

  def call
    User.active.each do |user|
      next unless user.send_unread_items_notifications?

      user.with_locale do
        user.in_time_zone do
          user.available_sites.each do |site|
            deliver_unread_items_for_site user, site
          end
        end
      end

    end

    Result.new success: true, notifications_sent: @mails_sent
  end

  private

  def deliver_unread_items_for_site(user, site)
    items = site.unread_items.for(user).includes(:item).map(&:item)

    items.reject! { |item|
      item.respond_to? :spam? and item.spam?
    }

    if items.any?
      Bold.with_site(site) do
        Notifications.unread_items(user.email, site, items.size).deliver
      end
      @mails_sent += 1
    end
  end

end

