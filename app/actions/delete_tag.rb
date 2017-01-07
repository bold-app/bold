class DeleteTag < ApplicationAction

  def initialize(tag, replace_with: nil)
    @tag = tag
    @replace_with = replace_with
  end

  def call
    if @replace_with
      @tag.taggings.update_all tag_id: @replace_with.id
    end
    @tag.destroy
  end

end
