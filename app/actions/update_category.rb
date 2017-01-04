class UpdateCategory < ApplicationAction

  Result = ImmutableStruct.new(:category_updated?, :category)

  def initialize(category, attributes = {})
    @category = category
    @attributes = attributes
  end

  def call
    @category.attributes = @attributes

    @category.transaction do

      slug_changed = @category.slug_changed?
      @category.save!

      if slug_changed
        CreatePermalink.call @category, @category.slug
      end

    end

    Result.new category: @category, category_updated: true

  rescue ActiveRecord::RecordInvalid
    Result.new category: @category
  end

end

