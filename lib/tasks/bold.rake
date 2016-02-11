# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#

namespace :bold do

  namespace :extensions do
    desc 'lists extensions'
    task :list => :environment do
      puts "Themes:"
      Bold::Theme.all.each do |id, theme|
        puts "  #{theme.name}"
      end
      puts "Plugins:"
      Bold::Plugin.all.each do |id, plugin|
        puts "  #{plugin.name}"
      end
    end
  end

  desc 'summarizes request logs for all sites'
  task :compute_stats  => :environment do
    if ENV['REBUILD_ALL'].present?
      Site.all.each(&:recompute_stats)
    else
      Site.all.each(&:compute_stats)
    end
  end

  namespace :site do

    desc 'summarizes request logs for named site into stats'
    task :compute_stats  => :environment do
      site = Site.where('hostname = :site or name = :site',
                        site: ENV['site']).first
      raise('site not found!') unless site
      if ENV['REBUILD_ALL'].present?
        site.recompute_stats
      else
        site.compute_stats
      end
    end

    desc 'import content into site'
    task :import => :environment do
      site = Site.where('hostname = :site or name = :site',
                        site: ENV['site']).first
      raise('site not found!') unless site
      file = ENV['file']
      site.import! file
    end

    desc 'export site content'
    task :export => :environment do
      site = Site.where('hostname = :site or name = :site',
                        site: ENV['site']).first
      raise('site not found!') unless site
      file = site.export!
      puts "exported to #{file}"
    end

  end
end
