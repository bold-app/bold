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
class CommentApprovalJob < ActiveJob::Base
  queue_as :default

  def perform(comment)
    Bold.with_site(comment.site) do
      case comment.spam_check!
      when :blatant
        Rails.logger.warn "deleting unseen blatant spam: #{comment.author_name} / #{comment.author_email}\n#{comment.body[0..99]}"
        comment.destroy
      when :ham
        comment.approved! if comment.auto_approve?
      else
        # spam, no approval
      end
    end
  end
end