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
class Frontend::ContentsController < FrontendController

  def show
    if @content = find_content
      render_content
    elsif @destination
      case @destination
      when Redirect
        redirect_to @destination.location,
          status: (@destination.permanent? ? :moved_permanently : :found)
      when Category
        category
      when Tag
        tag
      else
        not_found
      end
    else
      not_found
    end
  end

  # posts by year / month
  def archive
    if @content = current_site.archive_page
      render_content
    else
      raise ::Bold::NotFound.new("archive page not found")
    end
  end

  # posts by author
  def author
    if @content = current_site.author_page and @author = current_site.users.named(params[:author]).first
      render_content
    else
      raise ::Bold::NotFound.new("author page or author not found")
    end
  end

  private

  # posts by tag
  def tag
    @tag = @destination
    if @content = current_site.tag_page
      render_content
    else
      raise ::Bold::NotFound.new("tag page or tag not found")
    end
  end

  # posts by category
  def category
    @category = @destination
    if @content = current_site.category_page
      render_content
    else
      raise ::Bold::NotFound.new("category page or category not found")
    end
  end

  def not_found(msg = "path >#{params[:path]}< does not exist")
    raise ::Bold::NotFound.new msg
  end

end
