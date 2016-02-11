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
# https://github.com/rails/sprockets/issues/26

require 'zlib'

namespace :assets do
  task :gzip => :environment do
    logger = Logger.new(STDOUT)
    asset_root = Rails.root.join('public', 'assets')
    Dir["#{asset_root}/**/*.{js,css,html,svg}"].each do |asset|
      gz_asset_name = "#{asset}.gz"
      next if File.exist? gz_asset_name
      logger.info "#Compressing #{gz_asset_name}..."
      Zlib::GzipWriter.open(gz_asset_name, Zlib::BEST_COMPRESSION) do |gz_asset|
        gz_asset.mtime = File.mtime(asset)
        gz_asset.orig_name = asset
        gz_asset.write IO.binread(asset)
      end
    end
  end
end

Rake::Task['assets:precompile'].enhance { Rake::Task['assets:gzip'].invoke }