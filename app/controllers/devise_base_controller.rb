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
# base class for all Devise controllers
class DeviseBaseController < ApplicationController
  layout 'bold_public'
  helper :bold

  include Bold::I18n::AutoLocale
  around_action :set_locale

  private

  def after_sign_in_path_for(*args)
    bold_root_path
  end

  def after_sign_out_path_for(*args)
    new_user_session_path
  end

end