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
class Frontend::ContactMessagesController < FrontendController

  def create
    @content = find_content
    @contact_message = ContactMessage.new contact_message_params
    @contact_message.content = @content
    if @contact_message.save
      Notifications.contact_form_received(@contact_message).deliver_later
      redirect_to content_url(@content.path),
        notice: Bold::I18n.t('flash.contact_messages.created')
    elsif @contact_message.errors[:receiver_email].present?
      render nothing: true, status: 400
    else
      render_content
    end
  end

  private

  def contact_message_params
    params[:contact_message].permit :sender_name, :sender_email, :subject, :body
  end

end
