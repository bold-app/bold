require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  setup do
    @user = create :confirmed_admin
    @site = create :site, theme_name: 'test', post_comments: 'enabled'
    Bold.current_site = @site
    create :site_user, user: @user, site: @site, manager: true
    @post = create :published_post, author: @user
    @contact = create :page, author: @user, site: @site, template: 'contact_page', template_field_values: { contact_message_receiver: 'jk@bold-app.org' }
  end

  test "should send daily activity notification" do
    msg = create :contact_message, site: @site, content: @contact
    comment = create :comment, site: @site, content: @post

    assert @site.visitor_postings.recent.any?
    assert msg.content.present?
    assert mail = Notifications.daily_summary(@user, @site).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal %w(root@host.com), mail.from
    assert_match /#{msg.subject}/, mail.body.to_s
    assert_match /#{msg.sender_name}/, mail.body.to_s
    assert_match /#{comment.author_name}/, mail.body.to_s
    assert_match /#{comment.author_email}/, mail.body.to_s
    assert_match /on #{@post.title}/, mail.body.to_s
    assert_equal @user.email, mail.to.first.to_s
  end

end
