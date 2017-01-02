class DeleteContent < ApplicationAction

  Result = ImmutableStruct.new(:content_deleted?)

  def initialize(content)
    @content = content
  end

  def call
    return Result.new if @content.homepage?

    @content.transaction do
      @content.unpublish if @content.published?

      @content.permalink&.destroy
      # FIXME need to cleanup any redirects pointing here as well. problem is,
      # redirects just have a location(string)

      @content.update_attribute :deleted_at, Time.now

      Result.new content_deleted: true
    end
  end

end
