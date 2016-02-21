module TextStats
  def word_count
    WordsCounted.count(body).token_count
  end
end
