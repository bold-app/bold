class UpdateTag < ApplicationAction

  Result = ImmutableStruct.new(:tag_updated?)

  def initialize(tag, attributes)
    @tag = tag
    @attributes = attributes
  end

  def call
    @tag.attributes = @attributes

    @tag.transaction do

      slug_changed = @tag.slug_changed?
      @tag.save!

      if slug_changed
        CreatePermalink.call @tag, @tag.slug
      end

    end

    Result.new tag_updated: true

  rescue ActiveRecord::RecordInvalid
    Result.new
  end

end

