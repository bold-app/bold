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
class Comment < VisitorPosting
  include Markdown

  DATA_ATTRIBUTES = %i(
    author_name
    author_email
    author_website
    body
  )

  DATA_ATTRIBUTES.each do |attribute|
    store_accessor :data, attribute
  end

  validates :author_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :author_email, presence: true, format: /.+@.+\..{2,}/, length: { maximum: 100 }
  validates :author_website, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 10.kilobytes }

  validate :check_approval_config, on: :create

  after_create :trigger_spamcheck

  def auto_approve?
    site.auto_approve_comments?
  end

  def body_html
    md_render_text body
  end

  def to_s
    "#{author_name} (#{author_email}) on #{content.title}"
  end

  private

  def trigger_spamcheck
    CommentApprovalJob.perform_later(self)
  end

  def additional_akismet_attributes
    {
      author: author_name,
      author_email: author_email,
      author_url: author_website,
      type: 'comment',
      text: body,
      post_url: content.public_url,
      post_modified_at: content.post_date.iso8601,
    }
  end

  def check_approval_config
    unless site.comments_enabled? && content.published?
      errors[:base] << 'comments are disabled'
    end
  end

end
