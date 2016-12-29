class SiteRecord < ApplicationRecord

  self.abstract_class = true

  belongs_to :site, required: true

  after_initialize :set_current_site

  private

  def set_current_site
    self.site ||= Site.current
  end

end
