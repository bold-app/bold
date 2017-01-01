class UnreadItem < SiteRecord
  belongs_to :user, required: true
  belongs_to :item, polymorphic: true, required: true

  scope :for, ->(user_or_item){
    if User === user_or_item
      where user: user_or_item
    else
      where item: user_or_item
    end
  }

  def self.mark_as_read(item)
    UnreadItem.for(item).delete_all
  end
end
