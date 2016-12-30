class SiteSpam

  attr_reader :count

  def initialize(site)
    @spam = site.visitor_postings.spam
    @count = @spam.count
  end

  def any?
    count > 0
  end

  def delete
    @spam.delete_all
  end

end
