# unfortunately this never attaches the first event of a visit to it's visit.
# We use the JS based page view tracking for this reason.
class TrackRequest < ApplicationAction

  def initialize(ahoy, object:, permalink: nil, status:)
    @ahoy = ahoy
    @object = object
    @permalink = permalink
    @status = status
  end

  def call
    object = @object.respond_to?(:object) ? @object.object : @object

    case object
    when Content

      @ahoy.track(
        "page view", content_id: object.id,
                     content_class: object.type,
                     permalink: (@permalink || object.permalink)&.path,
                     status: @status,
                     site_id: object.site_id
      )

    when Asset

      @ahoy.track(
        "asset download", asset_id: object.id,
                          status: @status,
                          site_id: object.site_id
      )

    else

      # ?
    end
  end
end
