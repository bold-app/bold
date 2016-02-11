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
class Comment < ActiveRecord::Base
  include Markdown
  include SiteModel
  include Spamcheck

  belongs_to :post

  validates :author_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :author_email, presence: true, format: /.+@.+\..{2,}/, length: { maximum: 100 }
  validates :author_website, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 20.kilobytes }
  validate :check_approval_config, on: :create

  before_validation :init_status, on: :create

  memento_changes :update, :destroy

  enum status: %i(pending approved spam)
  def init_status
    self.status ||= :pending
    self.comment_date ||= Time.zone.now
  end

  # Manually mark a Comment as 'Not Spam'.
  # To allow proper undo we wait an hour before doing the actual Akismet update.
  # Undo will then restore the old state and remove the pending job.
  def mark_as_ham!
    pending!
    report_ham!
  end

  # Manually mark the comment as Spam.
  # To allow proper undo we wait an hour before doing the actual Akismet update.
  # Undo will then restore the comment and remove the pending job.
  def mark_as_spam!
    report_spam!
    self.destroy
  end

  def auto_approve?
    site.auto_approve_comments?
  end

  def body_html
    md_render_text body
  end

  def take_current_site
    self.site_id ||= post.site_id
  end


  private

  def check_approval_config
    unless site.comments_enabled? && post.published?
      errors[:base] << 'comments are disabled'
    end
  end

end