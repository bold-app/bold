require 'test_helper'

class CreateAssetTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
    @file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'title_and_caption.jpg'), 'image/jpeg')
  end

  test 'should create asset from file' do
    asset = @site.assets.build file: @file
    assert_difference 'Asset.count' do
      assert r = CreateAsset.call(asset)
      assert r.asset_created?
      assert asset = r.asset
      assert_equal 'The title', asset.title
      assert_equal 120616, asset.file_size
      assert_equal 7, asset.tags.size
    end
  end

  test 'should create asset from url' do
    asset = @site.assets.build remote_file_url: 'https://oft-unterwegs.de/files/inline/7e9aaa6e-c1e4-48b6-8d70-e866ac01359f/teaser'
    assert_difference 'Asset.count' do
      assert r = CreateAsset.call(asset)
      assert r.asset_created?
      assert asset = r.asset
      assert_equal 45232, asset.file_size
    end
  end

  test 'should create scaler job' do
    asset = @site.assets.build file: @file
    assert_enqueued_with job: ImageScalerJob do
      CreateAsset.call(asset)
    end
  end

end
