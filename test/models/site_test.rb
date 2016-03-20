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

class SiteTest < ActiveSupport::TestCase

  setup do
    @site = create :site, theme_name: 'test', url_scheme: 'https', hostname: 'test.host'
    Bold::current_site = @site

    register_plugin :dummy do
      name 'Test plugin'
    end
  end

  teardown do
    unregister_theme :foo
    unregister_plugin :dummy
    FileUtils.rm_f @file if @file
  end

  test 'should validate uniqueness of hostname' do
    site = Site.new hostname: 'test.host'
    assert !site.valid?
    assert site.errors[:hostname].any?
  end

  test 'should have content pages' do
    assert pages = @site.content_pages
    assert pages.blank?, pages.inspect
    page = create :page, template: 'page'
    @site.reload
    assert pages = @site.content_pages
    assert pages.include?(page)
  end

  test 'should have authors' do
    assert authors = @site.authors
    assert authors.blank?
    create :page
    @site.reload
    assert authors = @site.authors
    assert authors.include?(User.current)
  end

  test 'should validate uniqueness of aliases' do
    @site.update_attribute :alias_string, 'foobar.io asdf.com'
    site = Site.new theme_name: 'test', name: 'test site',
                    hostname: 'test2.host',
                    alias_string: 'asdf.com, test.de'
    assert !site.valid?
    assert site.errors[:alias_string].any?
  end

  test 'should validate uniqueness of hostname vs aliases' do
    @site.update_attribute :alias_string, 'foobar.io asdf.com'
    site = Site.new theme_name: 'test', name: 'test site',
                    hostname: 'foobar.io'
    assert !site.valid?
    assert site.errors[:hostname].any?
  end

  test 'should validate uniqueness of aliases vs hostname' do
    site = Site.new theme_name: 'test', name: 'test site',
                    hostname: 'foobar.io', alias_string: @site.hostname
    assert !site.valid?
    assert site.errors[:alias_string].any?
  end

  test 'should init special pages' do
    assert @site.notfound_page
    assert_nil @site.notfound_page.permalink
    assert @site.tag_page
    assert_nil @site.tag_page.permalink
    assert @site.category_page
    assert_nil @site.category_page.permalink
    assert @site.archive_page
    assert_nil @site.archive_page.permalink
    assert @site.author_page
    assert_nil @site.author_page.permalink
    assert @site.search_page
    assert_equal 'search', @site.search_page.path
  end

  test 'should init navigation' do
    assert_equal 1, @site.navigations.size
    assert nav = @site.navigations.first
    assert nav.first?
    assert_equal 1, nav.position
    assert_equal 'Home', nav.name
    assert_equal @site.external_url, nav.url
  end

  test 'should generate url' do
    assert_equal 'https://test.host/foo', @site.external_url('foo')
    assert_equal 'https://test.host/foo', @site.external_url('/foo')
    assert_equal 'https://test.host/', @site.external_url('')
    assert_equal 'https://test.host/', @site.external_url('/')
    assert_equal 'https://test.host/', @site.external_url(nil)
    assert_equal 'https://test.host/', @site.external_url()
  end

  test 'should store default locale' do
    @site.default_locale = 'de'
    assert @site.save
    @site.reload
    assert_equal 'de', @site.default_locale
  end

  test 'should have locales from theme' do
    assert_equal %w(en de), @site.available_locales
  end

  test 'should handle plugins' do
    assert @site.plugins.blank?
    assert !@site.plugin_enabled?('dummy')

    @site.enable_plugin! 'dummy'
    @site.reload
    assert_equal 1, @site.plugins.size
    assert @site.plugin_enabled?('dummy')

    @site.disable_plugin! 'dummy'
    @site.reload
    assert @site.plugins.blank?
    assert !@site.plugin_enabled?('dummy')
  end

  test 'should generate export and import it again' do
    assert_equal Site.current, @site
    asset = create :asset
    category = create :category, name: 'A category'
    post = create :published_post, title: 'hello from site 1', body: 'lorem ipsum', site: @site, category: category
    assert @site.assets.include?(asset)
    assert @site.contents.include?(post)
    assert f = @file = @site.export!('/tmp')
    assert File.size(f) > 0
    assert_match /.+\.zip$/, f
    assert listing = `unzip -l #{f}`.lines
    assert listing.detect{ |l| l =~ /contents.yml/ }
    assert listing.detect{ |l| l =~ /assets.yml/ }
    assert listing.detect{ |l| l =~ /categories.yml/ }
    assert listing.detect{ |l| l =~ /assets\/#{asset.id}\/#{asset.filename}/ }

    @site.destroy
    assert Asset.count.zero?
    assert Content.count.zero?
    another_site = Site.create! theme_name: 'test', hostname: 'acme.com', name: 'test 2'
    assert_difference 'another_site.contents.count', 1 do
      assert_difference 'another_site.assets.count', 1 do
        assert_difference 'another_site.categories.count', 1 do
          another_site.import! f
          another_site.reload
        end
      end
    end
    assert_equal 'A category', another_site.categories.first.name
  end

  test 'should downcase hostname upon creation' do
    site = create :site, hostname: 'FOObar.de'
    assert_equal 'foobar.de', site.hostname
  end

  test 'should create homepage on create' do
    assert site = @site
    assert page = site.homepage
    assert_equal 'homepage', page.slug
    assert_equal 'Homepage', page.title
    assert_equal site, page.site
    assert_nil page.permalink
  end

  test 'should store aliases' do
    @site.alias_string = 'foo.de,bar.com baz.com, aaaa.co'
    assert_equal 4, @site.aliases.size
    assert @site.save
    @site.reload
    assert_equal 4, @site.aliases.size
    assert_equal 'foo.de bar.com baz.com aaaa.co', @site.alias_string
  end

  test 'should enable new theme' do
    register_theme :foo do
      template :default
      template :page
      settings defaults: { a_setting: 'default value' }
    end
    @site.enable_theme! 'foo'
    @site.reload
    assert_equal 'foo', @site.theme_name
  end

  test 'should configure itself for theme' do
    register_theme :foo do
      template :default
      template :page
      settings defaults: { a_setting: 'default value' }
    end
    site = create :site, theme_name: 'foo'
    assert site.theme_config
    assert !site.theme_config.new_record?
    assert_equal 'default', site.theme_config.default_post_template
    assert_equal 'page', site.theme_config.default_page_template
    assert site.theme_config.configured?
    assert_equal 'default value', site.theme_config.config['a_setting']
  end

  test 'should find for hostname or alias' do
    site = create :site, hostname: 'FOObar.de', aliases: %w(www.foobar.de)
    assert_equal site, Site.for_hostname('fOobar.de')
    assert_nil Site.for_hostname('foobars.de')
    assert_equal site, Site.for_hostname('www.foobar.de')
  end

end
