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

class UndoTest < BoldIntegrationTest

  setup do
    unless defined? Poltergeist
      Capybara.current_driver = Capybara.javascript_driver
      @user = create :confirmed_user
      @site.update_attributes post_comments: 'enabled', akismet_key: '28736d172cca'

      ActiveJob::Base.queue_adapter = :delayed_job
    end
  end

  teardown do
    unless defined? Poltergeist
      ActiveJob::Base.queue_adapter = :test
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end

  test 'should remove and restore draft' do
    skip unless defined? Capybara::Poltergeist
    @post = create :published_post, title: 'Content title', body: 'Lorem ipsum ContentEditingTest', site: @site
    @post.body = 'This is the updated content.'
    assert_difference 'Draft.count' do
      @post.save
    end

    login_as @user
    visit '/bold'
    click_link 'Posts'
    click_link 'Content title'
    wait_for_ajax
    assert has_content?('updated content.')
    click_link 'Edit'
    assert has_content?('Draft saved on')
    click_link 'View changes'
    wait_for_ajax
    assert_difference 'Draft.count', -1 do
      click_link 'Delete draft'
    end
    assert !has_content?('updated content.')
    assert !has_content?('Draft saved on')
    assert has_content?('Lorem ipsum ContentEditingTest')

    click_link 'Undo'
    wait_for_ajax
    assert has_content?('Draft saved on')
    assert !has_content?('Lorem ipsum ContentEditingTest')
    assert has_content?('updated content.')

    logout
  end


  test 'should undo comment actions' do
    skip unless defined? Capybara::Poltergeist
    login_as @user
    p = create :published_post
    c = create :comment, content: p, author_name: 'Max Muster', body: 'test comment'
    date = c.created_at

    #
    # undo delete
    #
    visit '/bold/activity/comments'
    assert has_content? 'Max Muster'
    assert has_content? 'test comment'

    assert_difference '@user.undo_sessions.count' do
      assert_no_difference 'Comment.count' do
        assert_difference 'Comment.alive.count', -1 do
          click_link 'Delete'
          wait_for_ajax
        end
      end
    end

    assert_no_difference 'Comment.count' do
      assert_difference 'Comment.alive.count' do
        click_link 'Undo'
        wait_for_ajax
      end
    end

    assert restored_comment = Comment.find(c.id)
    assert_equal 'test comment', restored_comment.body
    assert_equal 'Max Muster', restored_comment.author_name
    assert restored_comment.pending?

    c = restored_comment

    #
    # undo mark as spam
    #
    visit '/bold/activity/comments'
    assert has_content? 'Max Muster'
    assert has_content? 'test comment'

    assert_difference '@user.undo_sessions.count' do
      assert_difference 'Delayed::Job.count' do
        assert_no_difference 'Comment.count' do
          assert_difference 'Comment.alive.count', -1 do
            click_link 'Spam'
            wait_for_ajax
          end
        end
      end
    end

    assert_no_difference 'Comment.count' do
      assert_difference 'Comment.alive.count' do
        # check removal of the spam report job:
        assert_difference 'Delayed::Job.count', -1 do
          click_link 'Undo'
          wait_for_ajax
        end
      end
    end

    assert restored_comment = Comment.find(c.id)
    assert_equal 'test comment', restored_comment.body
    assert_equal 'Max Muster', restored_comment.author_name
    assert restored_comment.pending?, restored_comment.inspect
    assert_equal date.to_i, restored_comment.created_at.to_i

    #
    # undo mark as ham
    #
    c.spam!

    visit '/bold/activity/comments'
    assert has_content? 'Max Muster'
    assert has_content? 'test comment'

    assert_difference '@user.undo_sessions.count' do
      assert_difference 'Delayed::Job.count' do
        assert_no_difference 'Comment.count' do
          click_link 'Not Spam'
          wait_for_ajax
        end
      end
    end

    c.reload
    assert c.pending?

    assert_no_difference 'Comment.count' do
      # check removal of the ham report job:
      assert_difference 'Delayed::Job.count', -1 do
        click_link 'Undo'
        wait_for_ajax
      end
    end

    c.reload
    assert c.spam?

  end

end
