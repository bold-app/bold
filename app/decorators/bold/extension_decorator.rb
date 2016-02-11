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
class Bold::ExtensionDecorator < Draper::Decorator
  delegate_all

  def author
    authors.join(', ')
  end

  def authors
    Array(object.author).flatten
  end

  def author_urls
    Array(ext.author_url).flatten
  end

  def authors_with_urls
    authors.zip author_urls
  end

  def self.decorate_all(*args)
    args.flatten.map{|o| decorate o}
  end
end