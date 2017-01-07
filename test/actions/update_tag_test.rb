#
# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

class UpdateTagTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should create new permalink when slug changes and redirect old link' do
    assert r = CreateTag.call('My Tag')
    assert r.tag_created?
    assert t = r.tag
    assert_equal 'my-tag', t.slug
    assert l = t.permalink
    assert_equal 'my-tag', l.path

    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        assert UpdateTag.call(t, slug: 'new-slug')
      end
    end

    t.reload
    assert l2 = t.permalink
    assert_equal 'new-slug', l2.path

    l.reload
    assert r = l.destination
    assert r.is_a?(Redirect)
    assert r.permanent?
    assert_equal '/new-slug', r.location
  end

  test 'should update name' do
    tag = CreateTag.call('Tag One').tag
    r = UpdateTag.call tag, name: 'new name'
    assert r.tag_updated?
    tag.reload
    assert_equal 'new name', tag.name
    assert_equal 'tag-one', tag.slug
  end


  test 'should reuse old redirected slug' do
    r = CreateTag.call 'Tag One'
    assert r.tag_created?
    tag = r.tag
    assert_equal 'tag-one', tag.slug

    r = UpdateTag.call tag, slug: 'new-slug'
    assert r.tag_updated?
    tag.reload
    assert_equal 'new-slug', tag.slug

    r = UpdateTag.call tag, slug: 'tag-one'
    assert r.tag_updated?
    tag.reload
    assert_equal 'tag-one', tag.slug
  end

end



