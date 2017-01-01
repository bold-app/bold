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
class ContactMessageSpamcheckJob < ActiveJob::Base
  queue_as :default

  def perform(contact_message)
    Bold.with_site(contact_message.site) do
      case contact_message.spam_check!

      when :blatant
        Rails.logger.warn "deleting unseen blatant spam: #{contact_message.sender_name} / #{contact_message.sender_email}\n#{contact_message.subject[0..99]}\n#{contact_message.body[0..99]}"
        UnreadItem.mark_as_read contact_message
        contact_message.destroy

      when :ham
        contact_message.approve!

      else
        # spam, no approval, mark as read
        UnreadItem.mark_as_read contact_message
      end
    end
  end
end

