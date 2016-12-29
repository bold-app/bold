class UnreadItem < SiteRecord
  belongs_to :user, required: true
  belongs_to :item, polymorphic: true, required: true

  scope :for, ->(user){ where user_id: user.id}
end
