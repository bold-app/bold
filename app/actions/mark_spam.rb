class MarkSpam < ApplicationAction

  def initialize(posting, blatant: false)
    @posting = posting
    @blatant = blatant
  end

  def call
    if @blatant
      DeletePosting.call @posting
    else
      # make appear as read
      UnreadItem.mark_as_read @posting
      @posting.spam!
    end
  end

end
