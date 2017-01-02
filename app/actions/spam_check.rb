require 'akismet/client'

class SpamCheck < ApplicationAction

  Result = ImmutableStruct.new(:spam?, :blatant?)

  def initialize(posting)
    @posting = posting
    @site = posting.site
  end

  def call
    client = Bold::AkismetClient.new(@site)

    if client.akismet_possible?

      is_spam, is_blatant = client.run_akismet_check(
        Bold::AkismetArgs.new(@posting)
      )
      Result.new spam: is_spam, blatant: is_blatant

    else
      Result.new
    end
  end

end

