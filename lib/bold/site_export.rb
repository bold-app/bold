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
  # TODO make sure permalinks stay the same during export/import cycle
  # atm they might change due to different order (at least once we have
  # automatic fixing of collisions in place...)
  class SiteExport

    CONTENTS_YML    = 'contents.yml'
    CATEGORIES_YML  = 'categories.yml'
    ASSETS_YML      = 'assets.yml'
    ASSETS_DIR      = 'assets'

    def initialize(site, zipfile, zip_cmd = '/usr/bin/zip', unzip_cmd = '/usr/bin/unzip')
      @site = site
      @zipfile = zipfile
      @zip_cmd = zip_cmd
      @unzip_cmd = unzip_cmd
    end

    def export!
      FileUtils.mkdir_p File.dirname @zipfile
      in_tmp_dir do
        export_categories
        export_contents
        export_assets
        zip
      end
      return @zipfile
    end

    def import!
      Bold::Search::disable_indexing do
        in_tmp_dir do
          unzip
          import_assets
          import_categories
          import_contents
        end
      end
      RebuildFulltextIndexJob.perform_later(@site, 'Content')
      RebuildFulltextIndexJob.perform_later(@site, 'Asset')
      true
    end

    private

    def import_contents
      @content_map = {}
      import_from(CONTENTS_YML) do |record|
        id   = record.delete 'id'
        type = record.delete 'type'
        author_email = record.delete 'author_email'
        comments = record.delete 'comments'
        record.delete 'site_id'
        content = @site.contents.find_by_id(id) ||
          @site.contents.find_by_slug(record['slug']) ||
          type.constantize.new
        was_new = content.new_record?
        content.attributes = record
        if content.author.blank?
          content.author = User.find_by_email author_email
        end
        content.site = @site
        content.save_without_draft validate: false
        if was_new && id.present?
          content.update_columns id: id, created_at: record['created_at']
        end
        # in case we found the target content by slug, ids may differ
        @content_map[id] = content.id

        unless comments.blank?
          content.comments.delete_all
          comments.each do |comment|
            c = content.comments.build(comment)
            c.save(validate: false)
            c.update_columns status: comment['status'], created_at: comment['created_at'], updated_at: comment['updated_at']
          end
        end

      end
    end

    def export_contents
      File.open CONTENTS_YML, 'wb' do |f|
        YAML.dump @site.contents.all.map{|c| c.attributes.merge tag_list: c.tag_list, 'author_email' => c.author.try(:email) }, f
      end
    end

    def import_assets
      import_from(ASSETS_YML) do |record|
        file = record.delete 'file'
        id   = record.delete 'id'
        record.delete 'site_id'
        (@site.assets.find_by_id(id) || @site.assets.build).tap do |asset|
          was_new = asset.new_record?
          asset.with_deferred_post_processing do
            asset.attributes = record
            asset.file = File.new File.join ASSETS_DIR, id.to_s, file
            asset.save validate: false
            if was_new
              # restore id and created_at, correct file location
              file_dir = File.dirname asset.file.path
              old_id = asset.id
              asset.update_columns id: id, created_at: record['created_at']
              SafeShell.execute 'mv', file_dir, file_dir.sub(old_id, id)
            end
          end
        end
      end
    end

    def export_assets
      File.open ASSETS_YML, 'wb' do |f|
        assets = @site.assets.all.map do |a|
          begin
            dir = File.join ASSETS_DIR, a.id
            FileUtils.mkdir_p dir
            FileUtils.cp a.file.path, dir
            a.attributes
          rescue Exception
            log_error "could not export file for asset #{a.id}: #{$!}"
            nil
          end
        end
        YAML.dump assets.compact, f
      end
    end

    def export_categories
      File.open CATEGORIES_YML, 'wb' do |f|
        YAML.dump @site.categories.all.map(&:attributes), f
      end
    end

    def import_categories
      import_from(CATEGORIES_YML) do |record|
        id = record.delete 'id'
        cat = @site.categories.find_by_id(id) || @site.categories.build
        was_new = cat.new_record?
        cat.attributes = record
        cat.save validate: false
        if was_new && id.present?
          cat.update_columns id: id, created_at: record['created_at']
        end
      end
    end


    # TODO keep errors and show to user
    def log_error(msg)
      Rails.logger.error msg
    end

    def import_from(yml, &block)
      YAML.load(IO.read(yml)).each do |record|
        yield record.except('site_id')
      end if File.readable?(yml)
    end

    def unzip
      SafeShell.execute! @unzip_cmd, @zipfile
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