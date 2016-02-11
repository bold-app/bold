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

class BoldSearchContentIndexerTest < ActiveSupport::TestCase

  setup do
    @indexer = Content.indexer
  end

  test 'should build data for indexing' do
    cat = mock
    cat.stubs(:name).returns 'category'
    p = mock
    p.stubs(:title).returns 'the title'
    p.stubs(:teaser).returns nil
    p.stubs(:meta_title).returns 'meta title'
    p.stubs(:meta_description).returns 'meta desc'
    p.stubs(:body).returns 'the body'
    p.stubs(:category).returns cat
    p.stubs(:tag_list).returns 'foo, bar'
    assert data = @indexer.send(:data_for_index, p)
    assert_equal 4, data.size
    assert title = data[:a]
    assert_equal 'the title', title[0]
    assert_equal 'meta title', title[1]
    assert_equal 'the body', data[:d]
    assert_equal 'foo, bar category', data[:b]
    assert_nil data[:c][0]
    assert_equal 'meta desc', data[:c][1]
  end

end