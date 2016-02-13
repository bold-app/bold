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
class Permalink < ActiveRecord::Base
  include SiteModel

  attr_accessor :path_args
  belongs_to :destination, polymorphic: true

  validates :path, uniqueness: { scope: :site_id, case_sensitive: false }, presence: true
  validates :destination, presence: true

  before_validation :build_path

  def build_path
    if path_args
      self.path = path_args.flatten.map do |s|
        next if s.blank?
        s.to_url limit: 500, truncate_words: false, allow_slash: true
      end.compact.join('/')
    end
  end

  def redirect_to(path, is_permanent: true)
    path = "/#{path}" unless path.starts_with?('/')
    self.destination = Redirect.new(location: path,
                                    permanent: is_permanent,
                                    site: site)
  end

end
