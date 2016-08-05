require 'test_helper'

class CreatePermalinkTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should allow slashes in path components' do
    cat = create :category, name: 'my category', slug: 'my/category'

    assert_difference 'Permalink.count' do
      r = CreatePermalink.call cat, 'my/category'
      assert r.link_created?
      assert_equal 'my/category', r.link.path
    end
  end

  test 'should not create duplicate link' do
    cat = create :category, name: 'my category', slug: 'foo'
    tag = create :tag, name: 'foo', slug: 'foo'

    assert_difference 'Permalink.count' do
      r = CreatePermalink.call cat, 'foo'
      assert r.link_created?
      assert_equal cat, r.link.destination
    end

    assert_no_difference 'Permalink.count' do
      r = CreatePermalink.call tag, 'foo'
      assert !r.link_created?
    end
  end

  test 'should replace redirect' do
    redirect = create :redirect, location: '/bar'
    tag = create :tag, name: 'foo', slug: 'foo'

    r = CreatePermalink.call redirect, 'foo'
    assert r.link_created?

    assert_difference 'Redirect.count', -1 do
      assert_no_difference 'Permalink.count' do
        r = CreatePermalink.call tag, 'foo'
      end
    end
    assert r.link_created?
    assert_equal tag, r.link.destination
  end


end
