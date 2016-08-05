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

  test 'new page should have site' do
    p = Page.new title: 'my new page'
    assert_equal @site, p.site
  end

  test 'new page should have default template' do
    p = Page.new title: 'my new page'
    assert p.template.present?
  end

  test 'should have hit count' do
    assert p = create(:published_page, title: 'My Great Page')
    assert_equal 0, p.hit_count
    StatsPageview.build_for_log(create(:request_log, resource: p)).save!
    assert_equal 1, p.hit_count
  end

  test 'should auto-fix slug' do
    assert p = create(:page, title: 'My Great Page')
    assert p.update_attribute :slug, 'foo, bar'
    p.reload
    assert_equal 'foo-bar', p.slug
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

  test 'may be saved empty' do
    page = Page.new site: @site, title: 'blank page'
    assert page.save, page.errors.inspect
    page.reload
    assert page.draft?
    assert_equal 'blank page', page.title
    assert page.body.blank?
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


  test 'should unpublish page' do
    page = Page.new status: :published, last_update: 2.days.ago
    page.unpublish
    assert !page.published?
    assert page.draft?
    assert_equal nil, page.last_update
  end

  test 'should publish and set post date accordingly' do
    @page = build :page
    assert !@page.published?
    assert @page.publish
    assert @page.published?
    assert @page.post_date.present?
    assert_nil @page.last_update
  end

  test 'should not publish unchanged record' do
    @page = create :published_page
    assert !@page.publish
    assert_nil @page.last_update
  end

  test 'should publish update' do
    @page = create :published_page
    @page.title = 'new title'
    assert @page.publish
    assert @page.last_update.present?
  end

  test 'should find by slug but only published and for current site' do
    page = create :page
    assert_equal @site, page.site
    assert_equal @site, Site.current
    assert_nil Page[page.slug]
    page.update_attribute :status, :published
    assert_equal page, Page[page.slug]
    Bold.current_site = create(:site)
    assert_nil Page[page.slug]
  end
end
