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

class FulltextIndexTest < ActiveSupport::TestCase
  setup do
    Bold.current_site = @site = create :site
    @post = create :post
  end

  test 'should init tsv and be searchable' do
    FulltextIndex.create! data: { a: 'title lorem', b: 'this is the less important body' }, config: 'bold_english', searchable: @post

    assert FulltextIndex.where("plainto_tsquery(?) @@ tsv", 'title').any?
    assert FulltextIndex.where("plainto_tsquery(?) @@ tsv", 'the').blank?
    assert FulltextIndex.where("plainto_tsquery(?) @@ tsv", 'less').any?
  end

  test 'should update tsv with new data' do
    idx = FulltextIndex.create data: { a: 'title lorem', b: 'this is the less important body'}, config: 'bold_english', searchable: @post
    assert idx.persisted?, idx.errors.inspect

    idx.data = { a: 'new title' }
    assert idx.save
    idx.reload
    assert_equal 2, idx.tsv.split.size
  end
end
