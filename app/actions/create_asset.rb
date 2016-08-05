# Saves the given asset and makes it searchable.
class CreateAsset
  include Action

  Result = ImmutableStruct.new(:asset_created?, :asset)

  def initialize(asset)
    @asset = asset
  end

  def call
    @asset.site    ||= Site.current
    @asset.creator ||= User.current

    ExtractAssetMetadata.call @asset

    @asset.transaction do

      unless @asset.save
        raise ActiveRecord::Rollback
      end

      ApplyTags.call @asset

      IndexAsset.call @asset

      if @asset.scalable_image?
        ImageScalerJob.perform_later(@asset)
      end

      return Result.new asset_created: true, asset: @asset
    end

    return Result.new asset_created: false
  end

end
