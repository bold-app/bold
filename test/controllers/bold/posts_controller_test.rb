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
  class PostsControllerTest < ActionController::TestCase

    setup do
      @post = create :post, site: @site, template_field_values: { test: 'bar' }
    end

    test "should get index" do
      get :index
      assert_response :success
      assert posts = assigns(:contents)
      assert posts.include?(@post)
    end

    test 'should show post' do
      get :show, id: @post.id
      assert_response :success
      assert_select 'h2', @post.title
    end

    test "should get new and pre-select default template" do
      @site.theme_config.update_attribute :default_post_template, 'homepage'
      assert_no_difference 'Post.count' do
        get :new
      end
      assert_response :success
      assert post = assigns(:content)
      assert_equal 'homepage', post.template
    end

    test "should get edit" do
      get :edit, id: @post.id
      assert_response :success
      assert_equal @post, assigns(:content)
      assert_select 'input[value=bar]'
    end

    test 'should show template changer' do
      xhr :get, :change_template, id: @post.id
      assert_response :success
      assert_equal @post, assigns(:content)
    end

    test 'should change template' do
      patch :update_template, id: @post.id, content: { template: 'page' }
      assert_redirected_to edit_bold_post_url(@post)
      @post.reload
      assert_equal 'page', @post.template
    end

    test 'should update and publish post' do
      put :update, id: @post.id, content: { title: 'new title', body: 'whatever', post_date_str: 'tomorrow morning' }, publish: 1
      assert_redirected_to edit_bold_post_path(@post)
      @post.reload
      assert @post.post_date > Time.now
      assert_equal 'new title', @post.title
    end

    test 'should create draft for published post' do
      @post.publish!
      old_title = @post.title
      put :update, id: @post.id, content: { title: 'new title' }
      assert_redirected_to edit_bold_post_path(@post)
      @post.reload
      assert_equal old_title, @post.title
      @post.load_draft!
      assert_equal 'new title', @post.title
    end

    test 'should update unpublished post without creating a draft' do
      put :update, id: @post.id, content: { title: 'new title', tag_list: 'foo', template_field_values: { test: 'some value' } }
      assert_redirected_to edit_bold_post_path(@post)
      @post.reload
      assert_equal 'new title', @post.title
      assert_equal 'some value', @post.template_field_value('test')
      assert_equal 'foo', @post.tag_list
    end

    test 'should save tags to draft' do
      @post.publish!
      assert_no_difference 'Tag.count' do
        put :update, id: @post.id, content: { tag_list: 'foo,bar' }
      end
      assert_redirected_to edit_bold_post_path(@post)
      @post.reload
      assert_equal '', @post.tag_list
      @post.load_draft!
      assert_match /bar/, @post.tag_list
      assert_match /foo/, @post.tag_list
    end

    test 'should save template vars to draft' do
      @post.publish!
      put :update, id: @post.id, content: { template_field_values: { test: 'foo' } }
      assert_redirected_to edit_bold_post_path(@post)
      @post.reload
      assert_equal 'bar', @post.template_field_value('test')
      @post.load_draft!
      assert_equal 'foo', @post.template_field_value('test')
    end

    test 'should render diff' do
      @post.publish!
      @post.body = 'new content here'
      assert @post.save
      xhr :get, :diff, id: @post.id
      assert diff = assigns(:diff)
      assert diff.present?
    end

    test 'should delete draft' do
      @post.publish!
      @post.body = 'new content here'
      assert @post.save
      assert_difference 'Draft.count', -1 do
        delete :delete_draft, id: @post.id
      end
      assert_redirected_to edit_bold_post_path(@post)
    end

    test 'should destroy post' do
      assert_difference 'Post.count', -1 do
        delete :destroy, id: @post.id
      end
      assert_redirected_to bold_root_path
    end

    test 'should unpublish post' do
      @post.publish!
      assert_no_difference 'Post.count' do
        delete :destroy, id: @post.id
        assert_redirected_to edit_bold_post_url(@post)
      end
    end
  end
end