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
class Frontend::SitemapsController < FrontendController
  # TODO honor sitemap size limits (50000 entries / 10MB?) and split it up if
  # necessary.
  def show
    @homepage = current_site.homepage.decorate
    @posts = current_site.posts.published.decorate
    @pages = current_site.content_pages.published.decorate
    if current_site.tag_page
      @tags = TagDecorator.decorate_collection current_site.tags
    end
    if current_site.category_page
      @categories = current_site.categories.decorate
    end
    if current_site.author_page
      @authors = current_site.authors.decorate
    end
    respond_to do |format|
      format.xml
    end
  end
end