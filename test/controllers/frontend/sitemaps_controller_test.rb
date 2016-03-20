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

module Frontend
  class SitemapsControllerTest < ActionController::TestCase

    setup do
      @page = create :published_page, site: @site
      @category = create :category, site: @site
      @post = create :published_post, site: @site, tag_list: 'foo', category_id: @category.id
      @unpub = create :post, site: @site, title: 'not published'
    end

    test 'should show sitemap' do
      get :show, params: { format: :xml }
      assert_response :success
      assert @response.body !~ /#{Regexp.escape @unpub.slug}</
      assert_select 'loc', @page.public_url
      assert_select 'loc', @post.public_url

      assert_select 'loc', Tag.where(name: 'foo').first.public_url
      assert_select 'loc', @category.public_url
      assert_select 'loc', @post.author.decorate.canonical_url
    end

  end

end
