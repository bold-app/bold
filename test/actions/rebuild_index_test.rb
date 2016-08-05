require 'test_helper'

class RebuildIndexTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should rebuild content index' do
    create :post, title: 'findme', site: @site
    assert FulltextIndex.search('findme').blank?

    called = false
    RebuildIndex.new(@site, Content).call do |record|
      IndexContent.call(record)
      called = true
    end

    assert called, 'block should have been called'
    assert FulltextIndex.search('findme').any?
  end

  test 'should rebuild asset index' do
    @asset = create :asset, title: 'findme', site: @site
    assert FulltextIndex.search('findme').blank?

    called = false
    RebuildIndex.new(@site, Asset).call do |record|
      IndexAsset.call(record)
      called = true
    end

    assert called, 'block should have been called'
    assert FulltextIndex.search('findme').any?
  end

end
