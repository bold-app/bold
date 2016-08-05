class CreateTag
  include Action

  Result = ImmutableStruct.new(:tag_created?, :tag)

  def initialize(name, site: Bold.current_site)
    @site = site
    @name = name
  end

  def call
    @site.transaction do
      tag = @site.tags.build(name: @name)

      r = CreatePermalink.call tag, tag.slug
      unless r.link_created?
        # try again with a (hopefully) unique path
        r = CreatePermalink.call tag, "tag-#{tag.slug}"
      end

      if r.link_created? and tag.save
        return Result.new tag_created: true, tag: tag
      end

      raise ActiveRecord::Rollback
    end

    Result.new tag_created: false
  end

end
