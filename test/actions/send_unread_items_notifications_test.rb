require 'test_helper'

class SendUnreadItemsNotificationsTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
    @post = publish_post
    @user = create :confirmed_user
    create :site_user, user: @user, site: @site
    @emails = ActionMailer::Base.deliveries
    @emails.clear

    c = create :comment, content: @post
    UnreadItem.create! item: c, user: @user, site: @site

    Bold.current_site = nil # simulate being called outside of site context
  end

  test 'should not send mail if user does not want' do
    refute @user.send_unread_items_notifications?

    r = SendUnreadItemsNotifications.new.call
    assert r.success?
    assert_equal 0, r.notifications_sent

    assert @emails.blank?
  end

  test 'should send mail' do
    @user.update_attribute :send_unread_items_notifications, '1'
    @user.reload

    assert @user.send_unread_items_notifications?

    r = SendUnreadItemsNotifications.new.call
    assert r.success?
    assert_equal 1, r.notifications_sent

    assert_equal 1, @emails.size
    assert m = @emails.first
    assert_equal @user.email, m.to.first.to_s
    assert_match /1 unread message/, m.body.to_s
    assert_match /one unread message/, m.subject
  end

end

