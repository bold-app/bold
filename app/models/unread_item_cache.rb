class UnreadItemCache

  def initialize(site, user, items)
    @unread_items = site.unread_items.
      for(user).
      where(item_id: items.map(&:id))
    @unread_item_ids = @unread_items.pluck(:item_id)
  end

  def count
    @unread_item_ids.size
  end

  def mark_all_read!
    @unread_items.delete_all
  end

  # we have UUID primary keys, thus the item_type can be safely ignored
  def unread?(item)
    @unread_item_ids.include? item.id
  end

end
