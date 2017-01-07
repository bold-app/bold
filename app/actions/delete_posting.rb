class DeletePosting < ApplicationAction

  Result = ImmutableStruct.new(:posting_deleted?)

  def initialize(posting)
    @posting = posting
    @site = posting.site
  end

  def call
    @posting.transaction do
      @site.unread_items.for(@posting).delete_all
      @posting.update_attribute :deleted_at, Time.now
    end
    Result.new posting_deleted: true
  end
end
