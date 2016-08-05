require 'test_helper'

class ImportSiteTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  teardown do
    FileUtils.rm_f @file if @file
  end

  test 'should import zip archive' do
    create :asset
    cat = create :category, name: 'A category'
    create :published_post, title: 'hello from site 1',
                            body: 'lorem ipsum',
                            site: @site,
                            category: cat

    @file = ExportSite.call @site, destination: '/tmp'

    @site.destroy
    assert Asset.count.zero?
    assert Content.count.zero?

    another_site = create :site, hostname: 'acme.com', name: 'test 2'

    assert_difference 'another_site.contents.count', 1 do
      assert_difference 'another_site.assets.count', 1 do
        assert_difference 'another_site.categories.count', 1 do
          ImportSite.call another_site, @file
          another_site.reload
        end
      end
    end
    assert_equal 'A category', another_site.categories.first.name
  end

end

