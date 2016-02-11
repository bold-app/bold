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

class ContentSearchTest < ActiveSupport::TestCase
  setup do
    @site = create :site
    @category = create :category, name: 'Some Category'
    @post = Post.create template: 'post', title: 'search test title', body: 'This is the body TEXT', tag_list: 'a tag, bar', category: @category
  end

  test 'should be blank or present' do
    cs = ContentSearch.new
    assert cs.blank?
    assert !cs.present?

    cs.query = 'foo'
    assert !cs.blank?
    assert cs.present?
  end

  test 'should find post by title, body, tags and category' do
    cs = ContentSearch.new query: 'foo'
    assert cs.search(@site.contents).blank?

    %w(body title category tag).each do |query|
      cs.query = query
      assert cs.search(@site.contents).where(id: @post.id).any?, "should have found by #{query}"
    end
  end

  test 'should find post after tag update' do
    cs = ContentSearch.new query: 'bar'
    assert cs.search(@site.contents).where(id: @post.id).any?

    @post.tag_list = 'boom'; @post.save
    assert cs.search(@site.contents).where(id: @post.id).blank?
    cs.query = 'boom'
    assert cs.search(@site.contents).where(id: @post.id).any?
  end

end