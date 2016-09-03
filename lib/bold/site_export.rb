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
module Bold
  class SiteExport

    CONTENTS_YML    = 'contents.yml'
    ASSETS_YML      = 'assets.yml'
    ASSETS_DIR      = 'assets'

    attr_reader :errors

    def initialize(site, zipfile, zip_cmd = '/usr/bin/zip', unzip_cmd = '/usr/bin/unzip')
      @site = site
      @zipfile = zipfile
      @zip_cmd = zip_cmd
      @unzip_cmd = unzip_cmd
      @errors = []
    end

    def export!
      FileUtils.mkdir_p File.dirname @zipfile
      in_tmp_dir do
        export_contents
        export_assets
        zip
      end
      return @zipfile
    end


    private

    def export_contents
      contents = @site.contents.all.map do |c|
        c.attributes.
          reject{|attr, value| attr.to_s =~ /_id$/ }.
          merge(
            path: c.path,
            tag_list: c.tag_list,
            category: c.category&.name,
            author_email: c.author&.email,
          )
      end
      File.open(CONTENTS_YML, 'wb'){ |f| YAML.dump contents, f }
    end

    def export_assets
      assets = @site.assets.all.map do |a|
        begin
          dir = File.join ASSETS_DIR, a.id
          FileUtils.mkdir_p dir
          FileUtils.cp a.file.path, dir
          a.attributes.reject{|attr, value| attr.to_s =~ /_id$/ }
        rescue Exception
          log_error "could not export file for asset #{a.id}: #{$!}"
          nil
        end
      end
      File.open ASSETS_YML, 'wb' do |f|
        YAML.dump assets.compact, f
      end
    end

    def log_error(msg)
      errors << msg
      Rails.logger.error msg
    end

    def zip
      SafeShell.execute! @zip_cmd, '-r', @zipfile, '.'
    end

    def in_tmp_dir(&block)
      Dir.mktmpdir "site-#{File.exists?(@zipfile) ? 'im' : 'ex'}port-#{Time.zone.now.to_i}" do |dir|
        Dir.chdir dir do
          yield
        end
      end
    end

  end
end
