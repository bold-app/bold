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
class CommentDecorator < Draper::Decorator

  delegate :body_html, :author_name, :author_email, :to_param

  def author
    if object.author_website.present?
      website = object.author_website.downcase
      website = "http://#{website}" unless website.start_with?('http')
      h.link_to object.author_name, website, rel: 'nofollow'
    else
      object.author_name
    end
  end

  def author_image(size: 100, html: {})
    h.image_tag author_image_url(size), {width: size, height: size, alt: '', class: 'avatar'}.merge(html)
  end

  def author_image_url(size = 80)
    default_url = h.image_url(Bold::Gravatar::DEFAULT)
    Bold::Gravatar.url object.author_email, size, default_url
  end

  # TODO mark comments by author, once we keep that info
  def css_class
    'comment'
  end

  def date
    object.created_at
  end

end
