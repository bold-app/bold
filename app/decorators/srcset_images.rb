module SrcsetImages
  def image_path_for_asset(asset, size: :original, default: nil)
    if asset
      if iv = asset.site.image_version(size) and iv.srcset?
        size = iv.srcset_default.name
      end
      h.site.image_path asset, size: size
    else
      default
    end
  end

  def image(asset, size: :original, default: nil, html: {})
    html[:alt] ||= asset.title
    if iv = asset.site.image_version(size) and iv.srcset?
      html[:srcset] = iv.srcset_versions.map{ |v|
        "#{image_path_for_asset(asset, size: v.name, default: default)} #{v.width}w"
      }.join ", "
    end
    h.image_tag image_path_for_asset(asset, size: size, default: default), html

  end
end
