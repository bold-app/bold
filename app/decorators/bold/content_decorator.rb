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
class Bold::ContentDecorator < Draper::Decorator
  decorates Content
  delegate_all

  def title
    object.title
  end

  def desktop_hits
    hit_count_by_device_class[:desktop]
  end
  def mobile_hits
    hit_count_by_device_class[:mobile]
  end

  def hit_count_by_device_class
    @hits ||= object.hit_count_by_device_class || {}
  end

  def hit_count
    @hit_count ||= object.hit_count
  end

  def comment_count
    @comment_count ||= comments.count
  end

  def comments?
    comment_count > 0
  end

  def has_unpublished_changes?
    !object.new_record? and (object.draft? or object.has_draft?)
  end

end
