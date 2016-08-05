module HasSlug

  def self.prepended(base)
    base.class_eval do

      validates :slug,
        presence: true,
        uniqueness: { scope: :site_id, case_sensitive: false }

    end
  end

  def slug=(value)
    super value.to_s.to_url allow_slash: true
  end
end
