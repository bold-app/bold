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
class Bold::AssetDecorator < Draper::Decorator
  decorates Asset
  delegate_all

  def name
    title.present? ? title : filename
  end

  def creation_date
    I18n.l created_at.to_date, format: :long
  end

  def taken_on_date
    I18n.l taken_on.to_date, format: :long if taken_on.present?
  end

  def dimensions
    if image? and width.present? and height.present?
      "#{width} × #{height} px"
    end
  end

  def portrait?
    image? and width.present? and height.present? and width.to_i < height.to_i
  end

end
