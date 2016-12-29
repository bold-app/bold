module Deletable
  extend ActiveSupport::Concern

  included do
    scope :existing, ->{ where deleted_at: nil }
  end

  # true if not deleted
  def existing?; !deleted? end

  # true if deleted
  def deleted?
    deleted_at.present?
  end

  # marks this content as deleted
  def delete
    update_attributes deleted_at: Time.now
  end

end
