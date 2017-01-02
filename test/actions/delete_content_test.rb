require 'test_helper'

class DeleteContentTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
  end

  test 'should delete post' do
    post = publish_post

    assert_no_difference 'Post.count' do
      assert_difference 'Permalink.count', -1 do
        DeleteContent.call post
      end
    end

    post.reload
    assert post.deleted_at.present?
    assert_nil Post.existing.find_by_id(post.id)
  end


  test 'should delete page' do
    page = publish_page

    assert_no_difference 'Page.count' do
      assert_difference 'Permalink.count', -1 do
        DeleteContent.call page
      end
    end

    page.reload
    assert page.deleted_at.present?
    assert_nil Page.existing.find_by_id(page.id)
  end

end
