class IndexAsset < ApplicationAction

  def initialize(asset = nil)
    @asset = asset
  end

  def call(asset = @asset)
    return false if asset.nil?

    idx = asset.fulltext_indices.first_or_initialize(published: true)
    idx.data = asset.data_for_index
    idx.save!

  end

  def self.rebuild_index(site = Bold.current_site)
    indexer = new
    RebuildIndex.new(site, Asset).call do |asset|
      indexer.call asset
    end
  end

end
