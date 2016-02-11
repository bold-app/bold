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
  class ContentsControllerTest < ActionController::TestCase

    setup do
      @page = create :published_page
      @post = create :published_post, post_date: Time.local(2015, 07, 2),
        tag_list: 'foo, bar', author: @user
    end

    test 'should show page' do
      get :show, path: @page.path
      assert_response :success
      assert_select 'h2', @page.title
    end

    test 'should show category' do
      assert cat = create(:category, name: 'New Category')
      assert cat.persisted?
      @post.category_id = cat.id
      @post.publish!
      assert_equal @post, cat.posts.first
      get :show, path: cat.path
      assert_response :success
      assert_select 'h2', /#{cat.name}/
      assert_select 'h3', /#{@post.title}/
    end

    test 'should render 404 for unknown path' do
      get :show, path: 'do-not-find-me'
      assert_response :not_found
    end

    test 'should render empty archive for year' do
      get :archive, year: '2011'
      assert_response :success
      assert_select 'h2', "2011"
    end
    test 'should render archive for year' do
      get :archive, year: '2015'
      assert_response :success
      assert_select 'h2', "2015"
      assert_select 'h3', @post.title
    end

    test 'should render empty archive for month' do
      get :archive, year: '2015', month: '01'
      assert_response :success
      assert_select 'h2', "January 2015"
    end

    test 'should render archive for month' do
      get :archive, year: '2015', month: '07'
      assert_response :success
      assert_select 'h3', @post.title
      assert_select 'h2', "July 2015"
    end

    test 'should render by author listing' do
      get :author, author: @user.name
      assert_response :success
      assert_select 'h2', "Posts by #{@user.name}"
      assert_select 'h3', @post.title
    end

    test 'should render tag listing' do
      assert @post.tag_list =~ /bar/
      get :show, path: 'bar'
      assert_response :success
      assert_select 'h2', 'Posts tagged bar'
      assert_select 'h3', @post.title

      # we should not have this kind of metadata on listing pages:
      assert_no_match /name='author'/, @response.body
      assert_no_match /itemprop='datePublished'/, @response.body
    end

    test 'should render search page' do
      get :show, path: 'search'
      assert_response :success
    end

    test 'should render search results' do
      get :show, path: 'search', q: 'foobar'
      assert_response :success
      assert_select 'h3', count: 0

      get :show, path: 'search', q: 'bar'
      assert_response :success
      assert_select 'h3', @post.title
    end

    test 'should create request log' do
      assert_difference 'RequestLog.count' do
        get :show, path: @page.path
      end
      assert l = RequestLog.order('created_at').last
      assert_equal 200, l.status
      assert_equal @page, l.resource
      assert_equal @page.site, l.site
    end

    test 'should record 404' do
      assert_difference 'RequestLog.count' do
        get :show, path: 'foo-bar'
      end
      assert l = RequestLog.order('created_at').last
      assert_equal 404, l.status
      assert l.path['foo-bar']
      assert_nil l.resource
      assert_equal @site, l.site
      assert_nil l.permalink
    end

  end

end