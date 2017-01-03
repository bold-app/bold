class UpdateCategory < ApplicationAction

  def initialize(category, attributes = {})
    @category = category
    @attributes = attributes
  end

  # FIXME return meaningful result object
  def call
    @category.attributes = @attributes
    Category.transaction do
      if @category.slug_changed?
        CreatePermalink.call @category, @category.slug
      end
      @category.save!
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end

