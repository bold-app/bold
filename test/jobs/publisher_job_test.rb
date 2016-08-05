#
# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

class PublisherJobTest < ActiveJob::TestCase
  setup do
    @site = create :site
    @user = create(:confirmed_user)
    @site.add_user! @user
    @post = publish_post author: @user, post_date: (Time.now + 5.minutes)
  end

  test 'should publish post' do
    @post.update_column :post_date, (Time.now - 5.minutes)
    assert @post.scheduled?
    PublisherJob.perform_now @post
    @post.reload
    assert @post.published?
  end

  test 'should reschedule if post is not due yet' do
    assert @post.scheduled?
    assert_enqueued_with(job: PublisherJob, args: [@post]) do
      PublisherJob.perform_now @post
    end
    @post.reload
    assert @post.scheduled?
  end
end
