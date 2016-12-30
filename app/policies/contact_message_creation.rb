class ContactMessageCreation < ApplicationPolicy

  def initialize(content)
    @content = if content.is_a? ContentDecorator
      content.object
    else
      content
    end
  end

  # FIXME property on site / contact form page / template?
  def allowed?
    @content.is_a?(Page)
  end

end

