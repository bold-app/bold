require 'test_helper'

class CreateImageVersionTest < ActiveSupport::TestCase

  setup do
    @path = Rails.root/'test'/'fixtures'/'photo.jpg'
  end

  teardown do
    FileUtils.rm_f @dest
  end

  test 'should create scaled image version' do
    cfg = { name: 'small', width: 200, ratio: 2, quality: 50, crop: false }
    r = CreateImageVersion.call @path, cfg
    assert r.version_created?
    assert @dest = r.path
    img = MiniMagick::Image.open @dest
    assert_equal 133, img[:width]
    assert_equal 100, img[:height]
  end

  test 'should create cropped image version' do
    cfg = { name: 'cropped', width: 200, ratio: 2, quality: 50, crop: true }
    r = CreateImageVersion.call @path, cfg
    assert r.version_created?
    assert @dest = r.path
    img = MiniMagick::Image.open @dest
    assert_equal 200, img[:width]
    assert_equal 100, img[:height]
  end

end
