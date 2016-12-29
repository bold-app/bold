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
      Bold.current_site = @site
    end

    test "should get index" do
      p = save_post
      get :index, params: { site_id: @site.id }
      assert_response :success
      assert posts = assigns(:contents)
      assert posts.include?(p)
    end

    test 'should show post' do
      p = save_post
      get :show, params: { id: p.id }
      assert_response :success
      assert_select 'h2', p.title
    end

    test "should get new and pre-select default template" do
      @site.theme_config.update_attribute :default_post_template, 'homepage'
      assert_no_difference 'Post.count' do
        get :new, params: { site_id: @site.id }
      end
      assert_response :success
      assert post = assigns(:content)
      assert_equal 'homepage', post.template
    end

    test "should get edit" do
      p = save_post template_field_values: { test: 'bar' }
      get :edit, params: { id: p.id }
      assert_response :success
      assert_equal p, assigns(:content)
      assert_select 'input[value=bar]'
    end

    test 'should show template changer' do
      p = save_post
      get :change_template, xhr: true, params: { id: p.id }
      assert_response :success
      assert_equal p, assigns(:content)
    end

    test 'should change template' do
      p = save_post
      patch :update_template, params: { id: p.id, content: { template: 'page' } }
      assert_redirected_to edit_bold_post_url(p)
      p.reload
      assert_equal 'page', p.template
    end

    test 'should update and publish post' do
      p = save_post
      put :update, params: { id: p.id, content: { title: 'new title', body: 'whatever', post_date_str: 'tomorrow morning' }, publish: 1 }
      assert_redirected_to edit_bold_post_path(p)
      p.reload
      assert p.post_date > Time.now
      assert_equal 'new title', p.title
    end

    test 'should create draft for published post' do
      p = publish_post
      old_title = p.title
      put :update, params: { id: p.id, content: { title: 'new title' } }
      assert_redirected_to edit_bold_post_path(p)
      p.reload
      assert_equal old_title, p.title
      p.load_draft
      assert_equal 'new title', p.title
    end

    test 'should update unpublished post without creating a draft' do
      p = save_post
      put :update, params: { id: p.id, content: { title: 'new title', tag_list: 'foo', template_field_values: { test: 'some value' } } }
      assert_redirected_to edit_bold_post_path(p)
      p.reload
      assert_equal 'new title', p.title
      assert_equal 'some value', p.template_field_value('test')
      assert_equal 'foo', p.tag_list
    end

    test 'should save tags to draft' do
      p = publish_post
      assert_no_difference 'Tag.count' do
        put :update, params: { id: p.id, content: { tag_list: 'foo,bar' } }
      end
      assert_redirected_to edit_bold_post_path(p)
      p.reload
      assert_equal '', p.tag_list
      p.load_draft
      assert_match /bar/, p.tag_list
      assert_match /foo/, p.tag_list
    end

    test 'should save template vars to draft' do
      p = publish_post template_field_values: { test: 'bar' }
      put :update, params: { id: p.id, content: { template_field_values: { test: 'foo' } } }
      assert_redirected_to edit_bold_post_path(p)
      p.reload
      assert_equal 'bar', p.template_field_value('test')
      p.load_draft
      assert_equal 'foo', p.template_field_value('test')
    end

    test 'should render diff' do
      p = publish_post title: 'big news'
      p.body = 'new content here'
      SaveDraft.call p
      get :diff, xhr: true, params: { id: p.id }
      assert diff = assigns(:diff)
      assert diff.present?
    end

    test 'should delete draft' do
      p = publish_post title: 'big news'
      p.body = 'new content here'
      SaveDraft.call p
      assert_difference 'Draft.count', -1 do
        delete :delete_draft, params: { id: p.id }
      end
      assert_redirected_to edit_bold_post_path(p)
    end

    test 'should destroy unpublished post' do
      p = save_post
      assert_difference 'Post.existing.count', -1 do
        assert_no_difference 'Post.count' do
          delete :destroy, params: { id: p.id }
        end
      end
      assert_redirected_to bold_site_posts_path(site_id: @site)
    end

    test 'should unpublish post' do
      p = publish_post
      assert_no_difference 'Post.count' do
        delete :destroy, params: { id: p.id }
        assert_redirected_to edit_bold_post_url(p)
      end
    end
  end
end
