require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  setup do
    @site = create :site, theme_name: 'test', post_comments: 'enabled'
    Bold.current_site = @site
  end

  test "should send unread items notification" do
    assert mail = Notifications.unread_items('user@host.com', @site, 5).deliver_now

    assert ActionMailer::Base.deliveries.any?
    assert_equal %w(root@host.com), mail.from
    assert_match /5 unread messages/, mail.body.to_s
    assert_match /5 unread messages/, mail.subject
    assert_equal 'user@host.com', mail.to.first.to_s
  end

end
