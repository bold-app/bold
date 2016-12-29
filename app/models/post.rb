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
  prepend Taggable

  belongs_to :category


  scope :recent, ->(count){ existing.published.ordered.limit(count) }
  scope :ordered, ->{ order 'post_date DESC'.freeze }

  scope :for_year, ->(year){
    start = Time.zone.parse("#{year}-01-01")
    existing.where 'post_date between ? AND ?'.freeze, start, start.end_of_year
  }

  scope :for_month, ->(year, month){
    start = Time.zone.parse("#{year}-#{month}-01")
    existing.where 'post_date between ? AND ?'.freeze, start, start.end_of_month
  }


  # memento_changes :update, :destroy

  after_initialize :set_default_values


  def permalink_path_args
    [ publishing_year, publishing_month, slug ]
  end


  def comments
    Comment.existing.where(content_id: id)
  end

  # approved comments in ascending order
  #
  # FIXME how to best handle comment count > 100? comment paging in themes?
  def visible_comments(page = 0, limit = 100)
      comments.approved.
      order('created_at ASC').
      page(page).per(limit)
  end

  def auto_approve_comments?
    site.auto_approve_comments?
  end

  def comments_enabled?
    site.comments_enabled?
  end
  alias commentable? comments_enabled?

  # FIXME -> CommentAction
  def comment!(comment_params, request)
    Comment.new(comment_params).tap do |comment|
      comment.content = self
      comment.set_request request
      comment.save
    end
  end

  def data_for_index
    super.tap do |data|
      tags = tag_list
      if cat = category
        tags << ' ' << cat.name
      end
      data[:b] = tags
    end
  end


  private

  def set_default_values
    if new_record? && site
      self.template ||= site.theme_config.default_post_template
    end
  end

end
