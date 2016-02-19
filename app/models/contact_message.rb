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
class ContactMessage < VisitorPosting
  DATA_ATTRIBUTES = %i(
    body
    sender_email
    sender_name
    subject
  )

  DATA_ATTRIBUTES.each do |attribute|
    store_accessor :data, attribute
  end

  validates :subject,        presence: true, length: { minimum: 2, maximum: 300 }
  validates :sender_name,    presence: true, length: { minimum: 2, maximum: 100 }
  validates :sender_email,   presence: true, length: { maximum: 100 }, format: /.+@.+\..{2,}/
  validates :body,           presence: true, length: { minimum: 2, maximum: 10.kilobytes }

  after_create :trigger_spamcheck

  def receiver_email
    content.author.email
  end

  def to_s
    "#{subject} (#{sender_name} #{sender_email})"
  end

  private

  def trigger_spamcheck
    ContactMessageSpamcheckJob.perform_later(self)
  end

  def additional_akismet_attributes
    {
      author:       sender_name,
      author_email: sender_email,
      text:         "#{subject}\n#{body}",
      type:         'contact-form',
    }
  end

end
