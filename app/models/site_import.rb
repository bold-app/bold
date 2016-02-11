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

class SiteImport
  include ActiveModel::Model

  validates :zipfile, presence: true

  attr_accessor :zipfile, :local_file

  def valid?
    find_local_file
    super
  end

  def import_into(site)
    if valid?
      site.transaction do
        path = temp_path
        (File.new(path, 'wb') << zipfile.read).close
        ::Bold::SiteExport.new(site, path).import!
      end
    end
  rescue
    Rails.logger.error "error in import: #{$!}"
    Rails.logger.debug $!.backtrace.join "\n"
    return false
  end

  def available_files_for_import
    @available_files_for_import ||= find_available_files_for_import
  end

  def find_file_for_import(digest)
    available_files_for_import[digest]
  end

  private

  def find_local_file
    if local_file.present? and path = find_file_for_import(local_file)
      self.zipfile = File.new path
    end
  end

  def find_available_files_for_import
    Hash[ Dir[File.join(exports_dir, '*.zip')].sort{ |a, b|
      File.ctime(b) <=> File.ctime(a)
    }.map { |f|
      [Digest::SHA1.hexdigest(f), f]
    } ]
  end

  def exports_dir
    Rails.root.join 'exports'
  end

  def temp_path
    f = Tempfile.new 'site-import'
    f.path.tap do
      f.close
      f.unlink
    end
  end

end