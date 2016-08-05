require 'test_helper'

class CreateSiteTest < ActiveSupport::TestCase
  setup do
    @site = build :site, theme_name: 'test',
                         url_scheme: 'https',
                         hostname: 'test.host'
  end

  test 'should create site' do
    assert_difference 'Site.count' do
      r = CreateSite.call @site
      assert r.site_created?, r.error_message
    end
  end

  test 'should assign current user as manager' do
    assert_difference 'SiteUser.count' do
      CreateSite.call @site
    end
    @site.reload
    assert_equal Bold.current_user, @site.site_users.last.user
    assert_equal :manager, @site.site_users.last.role
  end

  test 'should create default navigation' do
    assert_difference 'Navigation.count' do
      CreateSite.call @site
    end
    assert nav = Navigation.last
    assert_equal 'Home', nav.name
    assert_equal @site.external_url, nav.url
  end

  test 'should create default content' do
    assert_difference 'Page.count', 8 do
      CreateSite.call @site
    end
    @site.reload
    assert @site.homepage
    assert @site.notfound_page
    assert @site.error_page
    assert @site.tag_page
    assert @site.category_page
    assert @site.author_page
    assert @site.archive_page
    assert @site.search_page
  end
end
