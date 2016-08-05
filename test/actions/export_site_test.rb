require 'test_helper'

class ExportSiteTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  teardown do
    FileUtils.rm_f @file if @file
  end

  test 'should generate export' do
    asset = create :asset
    category = create :category, name: 'A category'
    post = publish_post title: 'hello from site 1', body: 'lorem ipsum', site: @site, category: category
    assert @site.assets.include?(asset)
    assert @site.contents.include?(post)
    @file = ExportSite.call @site, destination: '/tmp'
    assert @file
    assert File.size(@file) > 0
    assert_match /.+\.zip$/, @file
    assert listing = `unzip -l #{@file}`.lines
    assert listing.detect{ |l| l =~ /contents.yml/ }
    assert listing.detect{ |l| l =~ /assets.yml/ }
    assert listing.detect{ |l| l =~ /categories.yml/ }
    assert listing.detect{ |l| l =~ /assets\/#{asset.id}\/#{asset.filename}/ }
  end

end
