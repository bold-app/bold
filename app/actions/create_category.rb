class CreateCategory < ApplicationAction

  Result = ImmutableStruct.new(:category_created?, :category)

  def initialize(attributes, site: Bold.current_site)
    @category_attributes = attributes
    @site = site
  end

  def call
    category = @site.categories.build @category_attributes
    category.transaction do

      if category.save
        r = CreatePermalink.call category, category.slug
        unless r.link_created?
          # try again with a (hopefully) unique path
          r = CreatePermalink.call category, "category-#{category.slug}"
        end

        if r.link_created?
          return Result.new category_created: true, category: category
        end
      end

      raise ActiveRecord::Rollback
    end

    Result.new category_created: false, category: category
  end

end
