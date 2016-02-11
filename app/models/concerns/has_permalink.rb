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
  extend ActiveSupport::Concern
  include SiteModel
  include Rails.application.routes.url_helpers

  included do
    has_one :permalink, as: :destination
    before_validation :init_slug
    before_validation :create_or_update_permalink
    validate :add_permalink_errors

    # dependent: :destroy on the relation breaks the permalink swapping in
    # create_or_update_permalink, so we do it manually:
    after_destroy :remove_permalink
  end

  def path
    permalink.try :path
  end

  def remove_permalink
    permalink.try :destroy
  end
  private :remove_permalink

  def init_slug
    if slug.blank?
      self.slug = slug_attribute
    end
  end
  private :init_slug

  def slug=(value)
    super value.to_s.to_url allow_slash: true
  end

  def slug_attribute
    name
  end
  private :slug_attribute

  def permalink_path_args
    [ slug ]
  end
  private :permalink_path_args

  def add_permalink_errors
    if permalink && !permalink.valid?
      errors[:slug] += permalink.errors[:path]
    end
  end
  private :add_permalink_errors


  def create_or_update_permalink
    if path = permalink_path_args and !@skip_permalink
      new_link = Permalink.new site: site, destination: self, path_args: path
      new_path = new_link.build_path
      if old_link = self.permalink and old_link.path != new_path
        old_link.redirect_to new_path
        self.permalink = new_link
      end
      # prevent collision with existing redirect by removing it
      if existing_link = Permalink.find_by_path(new_path)
        if Redirect === existing_link.destination
          existing_link.destination.destroy
          self.permalink = existing_link
        end
      end
      self.permalink ||= new_link
    end
  end
  private :create_or_update_permalink

  # Returns the canonical url for linking to this content or asset, using the
  # primary hostname and default scheme of the site.
  #
  # Use this method for links from the backend to the live site.
  # For linking *between* public pages, use +content_url(object.path)+ or just
  # +path+ instead.
  def public_url
    site.public_url path if (!respond_to?(:published?) || published?)
  end

  # The path for linking to this content or asset.
  #def public_path(options = {})
  #  return unless published?
  #  options[:path] = self.path
  #  content_path options
  #end
end