require 'test_helper'

class CommentCreationTest < ActiveSupport::TestCase
  setup do
    Bold.current_site = @site = create :site
  end


  test 'should allow creation if configured' do
    @site.stubs(:comments_enabled?).returns true
    p = publish_post
    p.site = @site

    assert CommentCreation.allowed? p
  end

  test 'should not allow creation if comments are disabled' do
    @site.stubs(:comments_enabled?).returns false
    p = publish_post
    p.site = @site

    assert !CommentCreation.allowed?(p)
  end

  test 'should not allow creation for unpublished post' do
    @site.stubs(:comments_enabled?).returns true
    p = save_post
    p.site = @site

    assert !CommentCreation.allowed?(p)
  end

  test 'should not allow creation for page' do
    @site.stubs(:comments_enabled?).returns true
    p = publish_page
    p.site = @site

    assert !CommentCreation.allowed?(p)
  end
end
