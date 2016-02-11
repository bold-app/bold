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
require 'test_helper'

# patch SiteImport export lookup path
require 'site_import'
class SiteImport
  def exports_dir
    Rails.root.join 'test/fixtures'
  end
end

class SiteImportTest < ActiveSupport::TestCase

  test 'should find available files' do
    assert_equal 1, SiteImport.new.available_files_for_import.size
    assert_match /fixtures\/export.zip/, SiteImport.new.available_files_for_import.values.first
  end

  test 'should recognize zip file for hash' do
    hash = SiteImport.new.available_files_for_import.keys.first
    import = SiteImport.new local_file: hash
    assert import.valid?
  end
end