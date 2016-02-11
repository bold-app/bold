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
class ContactMessage < ActiveRecord::Base
  include SiteModel

  belongs_to :content
  belongs_to :user

  validates :subject,        presence: true
  validates :sender_name,    presence: true
  validates :sender_email,   presence: true
  validates :body,           presence: true

  validates :content,        presence: true
  validates :receiver_email, presence: true

  before_validation :find_receiver, on: :create

  private

  def find_receiver
    if content && content.template_field_value?(:contact_message_receiver)

      self.receiver_email = content.template_field_value(:contact_message_receiver)
      self.user = site.users.find_by_email receiver_email
    end
  end
end