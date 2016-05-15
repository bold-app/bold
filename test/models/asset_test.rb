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

class AssetTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
  end

  test 'should create from remote url' do
    asset = create :asset, file: nil, site: @site, remote_file_url: 'https://oft-unterwegs.de/files/inline/7e9aaa6e-c1e4-48b6-8d70-e866ac01359f/teaser'
    assert asset.image?
    assert asset.scalable?
    assert_equal 28907, asset.file_size
    assert asset.persisted?
  end

  test 'should detect image' do
    file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'photo.jpg'), 'text/plain')
    asset = Asset.create file: file
    assert asset.image?
    assert asset.scalable?
    assert_equal 'text/plain', asset.content_type
    assert_equal 'image/jpeg', asset.send(:magic_content_type)
  end

  test 'should detect fake image' do
    file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'test.txt'), 'image/jpeg')
    asset = Asset.create file: file
    assert !asset.image?
    assert !asset.scalable?
    assert_equal 'image/jpeg', asset.content_type
    assert_equal '', asset.send(:magic_content_type)
  end

  test 'should create scaler job' do
    assert_enqueued_with job: ImageScalerJob do
      @asset = create :asset, site: @site
    end
  end

  test 'should have set up indexer' do
    assert Bold::Search::AssetIndexer === Asset.indexer
  end

  test 'should rebuild index' do
    @asset = create :asset
    FulltextIndex.delete_all
    assert_difference 'FulltextIndex.count', 1 do
      Asset.rebuild_index
    end
  end

  test 'should index assets' do
    asset = nil
    assert_difference 'FulltextIndex.count', 1 do
      assert asset = create(:asset, title: 'this is the title')
    end
    assert asset.fulltext_indices.search('photo').map(&:searchable).include?(asset)
    assert asset.fulltext_indices.search('title').map(&:searchable).include?(asset)
  end

  test 'should return original for nil or :original version name' do
    @asset = create :asset
    assert_equal @asset.file.current_path, @asset.diskfile_path(nil)
    assert_equal @asset.file.current_path, @asset.diskfile_path(:original)
  end

  test 'should remove file upon destruction' do
    @asset = create :asset
    assert file = @asset.file.current_path
    assert File.file?(file), "expected file to be located at #{file}"
    assert @asset.readable?
    assert File.size(file) > 0
    @asset.destroy
    assert !File.file?(file)
    assert !@asset.readable?
  end

  test 'should store files by date and site' do
    @asset = create :asset
    assert file = @asset.file.current_path
    d = @asset.created_at
    assert file.include?("#{@site.id}/#{d.year}/#{d.month}/#{d.day}")
  end

  test 'should set slug from filename' do
    @asset = create :asset
    assert_equal 'photo', @asset.slug
  end

  test 'should store disk_directory' do
    @asset = create :asset
    @asset.reload
    assert dir = @asset.disk_directory
    assert dir.present?
    assert dir =~ /#{@asset.site_id}\/\d+\/\d+\/\d+\/#{@asset.id}/
  end

end
