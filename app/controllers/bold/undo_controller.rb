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
class Bold::UndoController < BoldController

  # roll back the changes recorded in undo session given by params[:id]
  def create
    if @undo_session = current_user.undo_sessions.find(params[:id])
      @undo_results = @undo_session.undo
      if @undo_results.success?
        flash.now[:notice] = 'bold.undo.success'
      else
        flash.now[:error] = 'bold.undo.failed'
      end
    end
  end
end