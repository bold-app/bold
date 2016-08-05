class ApplyTags
  include Action

  Result = ImmutableStruct.new(:success?, :tag_count)

  def initialize(taggable, tag_string = taggable.tag_list)
    @taggable = taggable
    @tag_string = tag_string
    @site = taggable.site
  end

  # tags that cannot be created for whatever reason are ignored.
  def call
    @taggable.transaction do

      @taggable.taggings = Tag.parse_tags(@tag_string).map do |name|
        unless tag = @site.tags.named(name).first
          r = CreateTag.call name, site: @site
          if r.tag_created?
            tag = r.tag
          end
        end

        if tag
          (tag.persisted? and @taggable.taggings.find_by_tag_id(tag.id)) or
            @taggable.taggings.build(tag: tag)
        else
          nil
        end
      end.compact

      if @taggable.save
        return Result.new success: true, tag_count: @taggable.taggings.count
      else
        raise ActiveRecord::Rollback
      end

    end

    return Result.new success: false
  end

end
