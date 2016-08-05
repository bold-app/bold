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

module Bold
  class PagesControllerTest < ActionController::TestCase

    setup do
      @page = create :page, site: @site
    end

    test "should get index" do
      get :index, params: { site_id: @site.id }
      assert_response :success
      assert pages = assigns(:contents)
      assert pages.include?(@page)
    end

    test "should get new" do
      assert_no_difference 'Page.count' do
        get :new, params: { site_id: @site.id }
      end
      assert_response :success
      assert page = assigns(:content)
      assert page.new_record?
    end

    test "should get edit" do
      get :edit, params: { id: @page.id }
      assert_response :success
      assert_equal @page, assigns(:content)
    end

    test 'should handle empty post' do
      assert_no_difference 'Page.count' do
        post :create, params: { site_id: @site.id, content: { title: '' }, publish: '1' }
      end
      assert_response :success
    end

    test 'should publish new page' do
      assert_difference 'Page.count' do
        post :create, params: { site_id: @site.id, content: { title: 'this is a new page' }, publish: '1' }
      end
      assert_redirected_to edit_bold_page_path(Page.order('created_at DESC').first)
    end

    test 'should update and publish page' do
      put :update, params: { id: @page.id, content: { title: 'new title' }, publish: '1' }
      assert_redirected_to edit_bold_page_path(@page)
      @page.reload
      assert_equal 'new title', @page.title
    end

    test 'should save page' do
      put :update, params: { id: @page.id, content: { title: 'new title' } }
      assert_redirected_to edit_bold_page_path(@page)
      @page.reload
      assert_equal 'new title', @page.title
    end

    test 'should save page draft for published page' do
      SaveContent.call @page, publish: true
      assert old_title = @page.title
      put :update, params: { id: @page.id, content: { title: 'new title' } }
      assert_redirected_to edit_bold_page_path(@page)
      @page.reload
      assert_equal old_title, @page.title
      @page.load_draft
      assert_equal 'new title', @page.title
    end

    test 'should delete page' do
      assert_difference 'Page.alive.count', -1 do
        assert_no_difference 'Page.count' do
          delete :destroy, params: { id: @page.id }
        end
      end
    end
  end
end
