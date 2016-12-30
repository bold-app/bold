require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site

    @post = publish_post

    @req = MockRequest.new(
      remote_ip: Faker::Internet.ip_v4_address,
      user_agent: 'test case',
      referrer: 'https://somewhere.else.com/',
      env: {}
    )
  end

  test 'should create unread items with comment' do
    user = create :confirmed_user
    create :site_user, user: user, site: @site

    c = @post.comments.build author_name: 'John',
                             author_email: Faker::Internet.email,
                             body: 'Hi! nice blog!'

    action = CreateComment.new c, @req, policy: YesPolicy

    assert user.unread_items.none?
    assert_difference 'UnreadItem.count' do
      r = action.call
      assert r.comment_created?
    end
    assert user.unread_items.any?
  end

  test 'should create comment' do
    c = @post.comments.build author_name: 'John',
                             author_email: Faker::Internet.email,
                             body: 'Hi! nice blog!'

    action = CreateComment.new c, @req, policy: YesPolicy

    assert_difference 'Comment.count' do
      r = action.call
      assert r.comment_created?
    end
  end

  test 'should not create comment if not allowed' do
    c = @post.comments.build author_name: 'John',
                             author_email: Faker::Internet.email,
                             body: 'Hi! nice blog!'

    action = CreateComment.new c, @req, policy: NoPolicy

    assert_no_difference 'Comment.count' do
      r = action.call
      assert !r.comment_created?
      assert_match /comments.+disabled/i, r.message
    end

  end

end
