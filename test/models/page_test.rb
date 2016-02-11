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

class PageTest < ActiveSupport::TestCase
  setup do
    @site = create :site
    Bold.current_site = @site
  end

  test 'should have hit count' do
    assert p = create(:published_page, title: 'My Great Page')
    assert_equal 0, p.hit_count
    StatsPageview.build_for_log(create(:request_log, resource: p)).save!
    assert_equal 1, p.hit_count
  end

  test 'should auto-fix permalink' do
    assert p = create(:page, title: 'My Great Page')
    assert p.update_attribute :slug, 'foo, bar'
    p.reload
    assert_equal 'foo-bar', p.slug
  end

  test 'should create permalink when published' do
    assert p = create(:page, title: 'My Great Page')
    assert_equal 'my-great-page', p.slug
    refute p.published?
    assert_nil p.permalink

    p.publish!
    p.reload
    assert p.published?
    assert l = p.permalink
    assert_equal 'my-great-page', l.path
  end

  test 'should replace old redirect when published' do
    assert p = create(:page, title: 'My Great Page')
    assert_equal 'my-great-page', p.slug
    p.publish!
    p.reload
    assert p.published?
    assert l = p.permalink
    assert_equal 'my-great-page', l.path

    assert_difference 'Permalink.count' do
      assert_difference 'Redirect.count' do
        p.slug = 'new-slug'
        assert p.publish!
      end
    end

    assert p2 = create(:page, title: 'My Great Page')
    assert_no_difference 'Permalink.count' do
      assert_difference 'Redirect.count', -1 do
        assert p2.publish!
      end
    end

  end

  test 'should store and retrieve template field values' do
    page = create :page, site: @site, template: 'homepage',
      template_field_values: {'foo' => 'bar'}
    page.save
    page.reload
    assert_equal 'bar', page.template_field_value('foo')
  end

  test 'should have template variables' do
    page = create :page, template: 'homepage'
    assert_equal 'homepage', page.get_template.name
  end

  test 'may be saved empty as draft' do
    page = Page.new site: @site, title: 'blank page'
    assert page.save, page.errors.inspect
    page.reload
    assert page.draft?
    assert_equal 'blank page', page.title
    assert page.body.blank?
  end

  test 'should store tags in draft' do
    page = create :published_page
    page.tag_list = 'foo'
    assert_equal 'foo', page.tag_list
    assert page.changed?
    assert_difference 'Draft.count' do
      assert page.save
    end
    page.reload
    assert page.has_draft?
    assert_equal '', page.tag_list
    page.load_draft!
    assert_equal 'foo', page.tag_list
  end

  test 'new record should save slug' do
    p = Page.new title: 'new title', site: @site
    assert p.save
    assert p.id
    assert_equal 'new title', p.title
    assert_equal 'new-title', p.slug
    assert p.draft?
    assert !p.published?
  end

  test 'should allow slug editing if not published' do
    @page = create :page
    assert_equal 'this-is-a-page', @page.slug
    @page.title = 'New title'

    assert @page.save
    @page.reload
    assert_equal 'this-is-a-page', @page.slug
    assert_equal 'New title', @page.title

    @page.slug = 'foo'
    assert @page.save
    @page.reload
    assert_equal 'New title', @page.title
    assert_equal 'foo', @page.slug

    @page.attributes = { title: 'foo bar', slug: '' }
    assert @page.save
    @page.reload
    assert_equal 'foo-bar', @page.slug
    assert_equal 'foo bar', @page.title
  end

  test 'should have template' do
    @page = create :page
    assert @page.get_template
  end

  test 'changed published page should save draft' do
    page = create :published_page
    assert !page.has_draft?
    page.title = 'new title'
    page.body = 'new body'
    assert page.save
    assert page.has_draft?

    assert page.draft.drafted_changes.key?('title'), page.draft.inspect
    assert page.draft.drafted_changes.key?('body'), page.draft.inspect

    page.reload
    assert_equal 'This is a Page', page.title
    assert_match /### H3 here/, page.body

    assert_equal 'new title', page.draft.drafted_changes['title']
    assert_equal 'new body', page.draft.drafted_changes['body']
    page.load_draft!
    assert_equal 'new title', page.title
    assert_equal 'new body', page.body
  end

  test 'new page should not save draft' do
    page = Page.new title: 'new page', body: 'new content', site: @site
    assert_difference 'Page.count', 1 do
      assert_no_difference 'Draft.count' do
        page.save
      end
    end
    page.reload
    assert page.draft?
    assert !page.published?
    assert !page.has_draft?
    assert !page.draft.present?
    assert_equal 'new page', page.title
    assert_equal 'new content', page.body
  end

  test 'page should remove draft upon republish' do
    page = create :published_page, title: 'pub title', body: 'pub body'
    assert page.published?
    assert_nil page.last_update
    assert_no_difference 'Page.count' do
      assert_difference 'Draft.count', 1 do
        page.update_attributes body: 'new body'
      end
    end
    page.reload
    assert page.published?
    assert page.has_draft?
    assert !page.draft?
    assert page.draft.present?
    assert_equal 'pub title', page.title
    assert_equal 'pub body', page.body
    assert_nil page.last_update

    page.load_draft!
    assert_equal 'new body', page.body

    page.body = 'changed again'
    assert page.publish!
    assert page.last_update
    page.reload
    assert !page.draft.present?
    assert_equal 'pub title', page.title
    assert_equal 'changed again', page.body
  end

  test 'should publish and set post dates accordingly' do
    @page = create :page
    assert !@page.published?
    assert @page.publish!
    @page.reload
    assert @page.published?
    assert @page.post_date.present?
    assert_nil @page.last_update

    assert @page.publish!
    assert_nil @page.last_update

    @page.title = 'new title'
    assert @page.publish!
    assert @page.last_update.present?
  end

  test 'should find by slug but only published and for current site' do
    page = create :page
    assert_equal @site, page.site
    assert_equal @site, Site.current
    assert_nil Page[page.slug]
    page.publish!
    assert_equal page, Page[page.slug]
    assert other_site = create(:site)
    assert_equal other_site, Site.current
    assert_nil Page[page.slug]
  end
end