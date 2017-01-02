require 'test_helper'

class ReportHamTest < ActiveSupport::TestCase

  setup do
    Bold::current_site = @site = create :site
  end

  test 'mark ham should change status of comment and enqueue job' do
    post = create :published_post
    co = create :comment, content: post
    co.spam!

    assert_enqueued_with(job: AkismetUpdateJob) do
      ReportHam.call co
    end
    co.reload

    assert co.pending?
  end

  test 'mark ham should change status of contact_message and enqueue job' do
    page = publish_page template: 'contact_page'
    co = create :contact_message, content: page
    co.spam!

    assert_enqueued_with(job: AkismetUpdateJob) do
      ReportHam.call co
    end
    co.reload

    assert co.pending?
  end

end
