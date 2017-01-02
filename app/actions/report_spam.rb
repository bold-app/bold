# Manually mark a posting as 'Spam'.
# To allow proper undo we wait an hour before doing the actual Akismet update.
# Undo will then restore the old state and remove the pending job.
#
# ReportSpam.call(comment)
#
class ReportSpam < ApplicationAction

  Result = ImmutableStruct.new(:success?)

  def initialize(posting)
    @posting = posting
    @site = posting.site
  end

  def call
    client = Bold::AkismetClient.new(@site)
    if client.akismet_possible?
      client.enqueue_akismet_job(
        :spam, ::Bold::AkismetArgs.new(@posting)
      )
    end

    DeletePosting.call @posting

    Result.new(success: true)
  end

end



