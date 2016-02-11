require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  setup do
    @site = create :site
    Bold.current_site = @site
    @post = create :published_post
    @contact = create :page, site: @site, template: 'contact_page', template_field_values: { contact_message_receiver: 'jk@bold-app.org' }
  end

  test "should send contact message notification" do
    msg = create :contact_message, site: @site, content: @contact
    assert msg.content.present?
    assert mail = Notifications.contact_form_received(msg).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal %w(root@host.com), mail.from
    assert_equal [msg.sender_email], mail.reply_to
    assert_match /#{msg.subject}/, mail.subject
    assert_match /#{msg.subject}/, mail.body.to_s
    assert_match /#{msg.body}/, mail.body.to_s
    assert_match /#{msg.sender_name}/, mail.body.to_s
    assert_equal 'jk@bold-app.org', mail.to.first.to_s
  end

  test 'should send comment notification' do
    co = create :comment, post: @post
  end
end
