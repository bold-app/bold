require 'test_helper'

class ReportSpamTest < ActiveSupport::TestCase

  setup do
    Bold::current_site = @site = create :site
  end

  test 'mark spam should mark comment as deleted and enqueue job' do
    post = create :published_post
    co = create :comment, content: post
    assert_no_difference 'Comment.count' do
      assert_difference 'Comment.existing.count', -1 do
        assert_enqueued_with(job: AkismetUpdateJob) do
          ReportSpam.call co
        end
      end
    end
  end

  test 'mark spam should mark contact message deleted and enqueue job' do
    page = publish_page template: 'contact_page'
    co = create :contact_message, content: page
    assert_no_difference 'ContactMessage.count' do
      assert_difference 'ContactMessage.existing.count', -1 do
        assert_enqueued_with(job: AkismetUpdateJob) do
          ReportSpam.call co
        end
      end
    end
  end

end

