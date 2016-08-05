class CreateCategory
  include Action

  Result = ImmutableStruct.new(:category_created?, :category)

  def initialize(category)
    @category = category
  end

  def call
    @category.transaction do

      r = CreatePermalink.call @category, @category.slug
      unless r.link_created?
        # try again with a (hopefully) unique path
        r = CreatePermalink.call @category, "category-#{@category.slug}"
      end

      if r.link_created? and @category.save
        return Result.new category_created: true, category: @category
      end

      raise ActiveRecord::Rollback
    end

    Result.new category_created: false
  end

end
