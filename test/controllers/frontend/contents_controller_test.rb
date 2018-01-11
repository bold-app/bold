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
    end

    test 'should show page' do
      p = publish_page
      get :show, params: { path: p.path }
      assert_response :success
      assert_select 'h2', p.title
    end

    test 'should render 404 for unknown paths' do
      get :show, params: { path: 'do-not-find-me' }
      assert_response :not_found
      get :show, params: { path: 'do-not-find-me.txt' }
      assert_response :not_found
      get :show, params: { path: 'do-not-find-me.jpg' }
      assert_response :not_found
      get :show, params: { path: 'do-not-find-me.xml' }
      assert_response :not_found
    end

    test 'should render nothing and 404 for invalid path with other content types' do
      @request.headers["Accept"] = "application/xml"
      get :show, params: { path: 'do-not-find-me.xml' }
      assert_response :not_found
      assert_equal '', @response.body

      @request.headers["Accept"] = "text/plain"
      get :show, params: { path: 'do-not-find-me.txt' }
      assert_response :not_found
      assert_equal '', @response.body
    end

    test 'should show category' do
      create_special_page :category
      cat = CreateCategory.call({ name: 'New Category'}, site: @site).category
      p = publish_post category: cat
      get :show, params: { path: cat.path }
      assert_response :success
      assert_select 'h2', /#{cat.name}/
      assert_select 'h3', /#{p.title}/
    end


    test 'should render empty archive for year' do
      create_special_page :archive
      get :archive, params: { year: '2011' }
      assert_response :success
      assert_select 'h2', "2011"
    end

    test 'should render archive for year' do
      p = publish_post post_date: Time.local(2015, 07, 2)
      create_special_page :archive
      get :archive, params: { year: '2015' }
      assert_response :success
      assert_select 'h2', "2015"
      assert_select 'h3', p.title
    end

    test 'should render empty archive for month' do
      create_special_page :archive
      get :archive, params: { year: '2015', month: '01' }
      assert_response :success
      assert_select 'h2', "January 2015"
    end

    test 'should render archive for month' do
      p = publish_post post_date: Time.local(2015, 07, 2)
      create_special_page :archive
      get :archive, params: { year: '2015', month: '07' }
      assert_response :success
      assert_select 'h3', p.title
      assert_select 'h2', "July 2015"
    end

    test 'should render by author listing' do
      p = publish_post author: @user
      create_special_page :author
      get :author, params: { author: @user.name }
      assert_response :success
      assert_select 'h2', "Posts by #{@user.name}"
      assert_select 'h3', p.title
    end

    test 'should render tag listing' do
      p = publish_post tag_list: 'foo, bar', author: @user
      create_special_page :tag
      get :show, params: { path: 'bar' }
      assert_response :success
      assert_select 'h2', 'Posts tagged bar'
      assert_select 'h3', p.title

      # we should not have this kind of metadata on listing pages:
      assert_no_match /name='author'/, @response.body
      assert_no_match /itemprop='datePublished'/, @response.body
    end

    test 'should render search page' do
      create_special_page :search
      get :show, params: { path: 'search' }
      assert_response :success
    end

    test 'should render search results' do
      create_special_page :search
      p = publish_post tag_list: 'foo, bar'

      get :show, params: { path: 'search', q: 'foobar' }
      assert_response :success
      assert_select 'h3', count: 0

      get :show, params: { path: 'search', q: 'bar' }
      assert_response :success
      assert_select 'h3', p.title
    end

  end

end
