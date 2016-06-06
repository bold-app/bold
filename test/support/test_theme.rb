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
require 'bold/theme'

Bold::Theme.register :test do
  name 'Test Theme'

  template :homepage, body: false
  template :post, fields: %w(teaser_image test)
  template :page
  template :contact_page
  template :tag, body: false
  template :not_found, fulltext_search: false
  template :author, body: false
  template :archive, body: false
  template :category, body: false
  template :search, body: false

  locales %w(en de)

  settings defaults: { subtitle: 'fancy subtitle' }

  render_on :view_layout_html_head_start, 'html_head'

  image_version :small, width: 280, height: 210, quality: 80, crop: true
  image_version :big, width: 1000, height: 1000, quality: 80, crop: false, alternatives: { mobile: { width: 750 } }
end

ActionController::Base.append_view_path 'test/support/views'
