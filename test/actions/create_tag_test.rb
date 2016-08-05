require 'test_helper'

class CreateTagTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should create tag' do
    assert_difference '@site.tags.count' do
      assert_difference 'Permalink.count' do
        r = CreateTag.call 'Foo'
        assert r.tag_created?
        assert t = r.tag
        assert_equal 'Foo', t.name
        assert_equal 'foo', t.slug
        assert l = t.permalink
        assert_equal 'foo', l.path
      end
    end
  end

  test 'should find non conflicting slug' do
    create :permalink, path: 'foo'

    assert_difference '@site.tags.count' do
      assert_difference 'Permalink.count' do
        r = CreateTag.call 'Foo'
        assert r.tag_created?
        assert t = r.tag
        assert_equal 'Foo', t.name
        assert_equal 'foo', t.slug
        assert l = t.permalink
        assert_equal 'tag-foo', l.path
      end
    end
  end


end

