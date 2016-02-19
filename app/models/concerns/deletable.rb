module Deletable
  extend ActiveSupport::Concern

  included do
    scope :alive, ->{ where deleted_at: nil }
  end

  # true if not deleted
  def alive?; !deleted? end

  # true if deleted
  def deleted?
    deleted_at.present?
  end

  # marks this content as deleted and destroys the permalink
  def delete
    update_attributes deleted_at: Time.now
  end

end
