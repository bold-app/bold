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
class Post < Content
  include Teaser

  has_many :comments, dependent: :delete_all
  belongs_to :category

  # memento_changes :update, :destroy

  scope :recent, ->(count){ alive.published.ordered.limit(count) }
  scope :ordered, ->{ order 'post_date DESC' }

  scope :for_year, ->(year){
    start = Time.zone.parse("#{year}-01-01")
    alive.where 'post_date between ? AND ?', start, start.end_of_year
  }

  scope :for_month, ->(year, month){
    start = Time.zone.parse("#{year}-#{month}-01")
    alive.where 'post_date between ? AND ?', start, start.end_of_month
  }

  after_initialize :set_default_values

  def permalink_path_args
    # only generate a permalink for published posts
    [ publishing_year, publishing_month, slug ] if published?
  end

  def publish!
    first_time = !published?
    super.tap do |success|
      if success && first_time && published?
        RpcPingJob.perform_later(self)
      end
    end
  end

  # approved comments in ascending order
  #
  def visible_comments(page = 0, limit = 100)
    comments.approved.order('comment_date ASC').page(page).per(limit)
  end

  def auto_approve_comments?
    site.auto_approve_comments?
  end

  def comments_enabled?
    site.comments_enabled?
  end
  alias commentable? comments_enabled?

  def comment!(comment_params, request)
    comments.build(comment_params).tap do |comment|
      comment.set_request request
      if comment.save
        CommentApprovalJob.perform_later(comment)
      end
    end
  end

  private

  def set_default_values
    if new_record? && site
      self.template ||= site.theme_config.default_post_template
    end
  end

end
