require 'test_helper'

class IndexContentTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should rebuild index' do
    create :post, title: 'findme'
    assert FulltextIndex.search('findme').blank?
    IndexContent.rebuild_index
    assert FulltextIndex.search('findme').any?
  end

  test 'should index published content' do
    post = nil
    assert_difference 'FulltextIndex.count', 1 do
      post = publish_post body: 'the quick brown fox'
    end
    assert post.published?

    post.reload

    assert_equal 1, post.fulltext_indices.size
    assert_equal 1, FulltextIndex.published.search('fox').size
    assert_equal 1, FulltextIndex.search('fox').size
  end

  test 'should maintain published and private version of index when published but edited' do
    post = nil
    assert_difference 'FulltextIndex.count' do
      post = publish_post body: 'find me'
    end
    assert post.published?
    post.body = 'the quick brown fox'
    assert SaveDraft.call(post)

    post.reload
    assert_equal 'find me', post.body

    assert_difference 'FulltextIndex.count' do
      assert IndexContent.new(post).call
    end

    assert_equal 2, post.fulltext_indices.size
    assert_equal 1, FulltextIndex.search('fox').size
    assert FulltextIndex.published.search('fox').blank?
    assert_equal 1, FulltextIndex.published.search('find').size
  end

  test 'should just create private version for unpublished post' do
    post = create(:post, body: 'find me')
    assert SaveDraft.call(post)

    assert_difference 'FulltextIndex.count', 1 do
      assert IndexContent.new(post).call
    end

    assert_equal 1, post.fulltext_indices.size
    assert FulltextIndex.published.search('find').blank?
    assert_equal 1, FulltextIndex.search('find').size
  end

  test 'should drop private version when published' do
    post = create(:post, body: 'find me')
    assert SaveDraft.call(post)

    assert_difference 'FulltextIndex.count', 1 do
      assert IndexContent.new(post).call
    end

    PublishContent.call post

    assert_no_difference 'FulltextIndex.count' do
      assert IndexContent.new(post).call
    end

    assert_equal 1, post.fulltext_indices.size
    assert_equal 1, FulltextIndex.published.search('find').size
    assert_equal 1, FulltextIndex.search('find').size
  end

end
