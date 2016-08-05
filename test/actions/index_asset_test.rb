require 'test_helper'

class IndexAssetTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should rebuild index' do
    @asset = create :asset, title: 'findme', site: @site
    assert FulltextIndex.search('findme').blank?
    IndexAsset.rebuild_index
    assert FulltextIndex.search('findme').any?
  end

  test 'should index assets' do
    asset = nil
    asset = create(:asset, title: 'this is the title')
    IndexAsset.call(asset)
    assert asset.fulltext_indices.search('photo').map(&:searchable).include?(asset)
    assert asset.fulltext_indices.search('title').map(&:searchable).include?(asset)
  end

end

