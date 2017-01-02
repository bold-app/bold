# Manually mark a posting as 'Not Spam'.
# To allow proper undo we wait an hour before doing the actual Akismet update.
# Undo will then restore the old state and remove the pending job.
#
# ReportHam.call(comment)
#
class ReportHam < ApplicationAction

  Result = ImmutableStruct.new(:success?)

  def initialize(posting)
    @posting = posting
    @site = posting.site
  end

  def call
    @posting.pending!

    client = Bold::AkismetClient.new(@site)
    if client.akismet_possible?
      client.enqueue_akismet_job(
        :ham, Bold::AkismetArgs.new(@posting)
      )
    end

    Result.new(success: true)
  end

end


