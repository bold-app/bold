module TextStats
  def word_count
    if body.blank?
      0
    else
      WordsCounted.count(body).token_count
    end
  end
end
