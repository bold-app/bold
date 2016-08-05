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
module HasPermalink

  def self.prepended(base)
    base.class_eval do
      has_one :permalink, as: :destination
      #validate :add_permalink_errors

      # dependent: :destroy on the relation breaks the permalink swapping in
      # create_or_update_permalink, so we do it manually:
      after_destroy :remove_permalink
    end
  end

  def path
    permalink&.path
  end

  # Returns the canonical url for linking to this content or asset, using the
  # primary hostname and default scheme of the site.
  #
  # Use this method for links from the backend to the live site.
  # For linking *between* public pages, use +content_url(object.path)+ or just
  # +path+ instead.
  def public_url
    permalink&.public_url if (!respond_to?(:published?) || published?)
  end

  def remove_permalink
    permalink&.destroy
  end
  private :remove_permalink

  #def add_permalink_errors
  #  if permalink && !permalink.valid?
  #    errors.add :slug, permalink.errors[:path]
  #  end
  #end
  #private :add_permalink_errors

end
