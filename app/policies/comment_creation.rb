class CommentCreation < ApplicationPolicy

  def initialize(content)
    @content = if content.is_a? ContentDecorator
      content.object
    else
      content
    end
  end

  def allowed?
    @content.is_a?(Post) and
      @content.published? and
      @content.site.comments_enabled?
  end

end
