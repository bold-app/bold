# Saves the given asset and makes it searchable.
class CreateAsset < ApplicationAction

  Result = ImmutableStruct.new(:asset_created?, :asset)

  def initialize(asset)
    @asset = asset
  end

  def call
    @asset.site ||= Site.current
    @asset.creator ||= User.current
    @asset.file_size = @asset.file.size

    @asset.transaction do

      unless @asset.save
        raise ActiveRecord::Rollback
      end

      ExtractAssetMetadata.call @asset

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
