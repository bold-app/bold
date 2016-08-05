require 'test_helper'

class ExtractAssetMetadataTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should set dimensions for non-jpg' do
    png = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'photo.png'), 'image/png')
    asset = create :asset, file: png
    ExtractAssetMetadata.call asset

    assert_equal 200, asset.width
    assert_equal 150, asset.height
  end

  test 'should set jpeg metadata' do
    jpg = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'title_and_caption.jpg'), 'image/jpeg')
    asset = create :asset, file: jpg
    ExtractAssetMetadata.call asset

    assert_equal 320, asset.width
    assert_equal 213, asset.height

    assert_equal 120616, asset.file_size
    assert_equal 'image/jpeg', asset.content_type

    assert_equal '2012-12-23', asset.taken_on.to_date.to_s
    assert_equal 'The title', asset.title
    assert_equal 'This is the Caption', asset.caption

    assert_equal 21, asset.lat.to_i
    assert_equal 105, asset.lon.to_i

  end

  test 'should set tags' do
    jpg = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'photo.jpg'), 'image/jpeg')
    asset = create :asset, file: jpg
    ExtractAssetMetadata.call asset
    assert asset.tag_list.present?
    assert asset.tag_list.include? 'Hanoi'
  end

end
