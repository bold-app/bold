require 'test_helper'

class ApplyTagsTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should tag post' do
    create :tag, name: 'Foo'
    p = create :post

    p.tag_list = 'foo, Bar, multi word'

    assert_difference 'Tag.count', 2 do
      assert_difference 'Tagging.count', 3 do
        r = ApplyTags.call p
        assert r.success?
        assert_equal 3, r.tag_count
      end
    end

    p.reload
    assert_match /multi word/, p.tag_list
    assert_match /Bar/, p.tag_list
    assert_match /Foo/, p.tag_list
  end

  test 'should choose non-conflicting slug' do
    create :permalink, path: 'foo'
    p = create :post

    assert_difference 'Tag.count' do
      assert_difference 'Tagging.count' do
        p.tag_list = 'foo'
        r = ApplyTags.call p
        assert r.success?
        assert_equal 1, r.tag_count
      end
    end

    assert t = @site.tags.named('Foo').first
    assert_equal 'foo', t.slug
    assert_equal 'tag-foo', t.permalink.path
  end

  test 'should remove unused tags' do
    p = create :post
    p.tag_list = 'removeme, "bar,baz"'
    r = ApplyTags.call p
    assert r.success?
    assert_equal 2, r.tag_count

    p.reload
    assert_match /removeme/, p.tag_list
    assert_match /"bar,baz"/, p.tag_list

    assert_difference 'Tag.count', -1 do
      assert_difference 'Tagging.count', -1 do
        p.tag_list = '"bar,baz"'
        r = ApplyTags.call p
        assert r.success?
        assert_equal 1, r.tag_count
      end
    end
  end

end
