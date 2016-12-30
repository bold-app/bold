require 'test_helper'

class CreateContactMessageTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site

    @page = publish_page

    @req = MockRequest.new(
      remote_ip: Faker::Internet.ip_v4_address,
      user_agent: 'test case',
      referrer: 'https://somewhere.else.com/',
      env: {}
    )

    @message = ContactMessage.new(
      subject: 'Hello',
      sender_name: 'John',
      sender_email: Faker::Internet.email,
      body: 'Hi! nice blog!',
      content: @page
    )
  end


  test 'should create unread items' do
    user = create :confirmed_user
    create :site_user, user: user, site: @site


    action = CreateContactMessage.new @message, @req, policy: YesPolicy

    assert user.unread_items.none?
    assert_difference 'UnreadItem.count' do
      r = action.call
      assert r.contact_message_created?
    end
    assert user.unread_items.any?
  end


  test 'should create ContactMessage' do
    action = CreateContactMessage.new @message, @req, policy: YesPolicy

    assert_difference 'ContactMessage.count' do
      r = action.call
      assert r.contact_message_created?
    end
  end


  test 'should not create comment if not allowed' do
    action = CreateContactMessage.new @message, @req, policy: NoPolicy

    assert_no_difference 'ContactMessage.count' do
      r = action.call
      assert !r.contact_message_created?
    end
  end

end

