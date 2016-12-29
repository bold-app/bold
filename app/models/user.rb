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
class User < ActiveRecord::Base
  include HasTimezone

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable,
         :invitable

  validates :email, presence: true, email: true

  has_many :site_users, dependent: :delete_all
  has_many :sites, through: :site_users
  has_many :contents, as: :author
  has_many :undo_sessions, class_name: 'Memento::Session'
  has_many :unread_items

  scope :active, ->{ where 'locked_at IS NULL AND confirmed_at IS NOT NULL' }
  scope :locked, ->{ where 'locked_at IS NOT NULL' }
  scope :unconfirmed, ->{ where locked_at: nil, confirmed_at: nil }
  scope :invited, ->{ where 'locked_at IS NULL AND confirmed_at IS NULL AND invitation_sent_at IS NOT NULL' }

  scope :by_name, ->{ order "LOWER(COALESCE(name, email)) ASC" }
  scope :named, ->(name){ where 'lower(name) = ?', name.to_s.unicode_downcase }

  PREFS = %i(
    time_zone_name
    backend_locale
    vim_mode
    hide_email
    meta_author_name
    meta_google_plus
    twitter_handle
  )
  PREFS.each do |attribute|
    store_accessor :prefs, attribute
  end
  def vim_mode?
    vim_mode.to_i == 1
  end

  def display_name
    name.blank? ? email.split('@')[0] : name
  end

  def role(site = Site.current)
    if admin?
      :admin
    elsif su = site_users.find_by_site_id(site.id)
      su.role
    else
      :none
    end
  end

  # user has permission to access the given site?
  # true if this user is a global admin, or an editor or manager of the given site
  def site_user?(site = Site.current)
    role(site) != :none
  end

  def available_sites
    admin? ? Site.all : self.sites
  end


  # true if this user is a global administrator or manager of the given site
  def site_admin?(site = Site.current)
    admin? || %i(manager admin).include?(role(site))
  end

  # prevent email from being changed without current password being checked
  def update_without_password(params, *options)
    params.delete :email
    super
  end

  def pending_invitation?
    invitation_sent_at.present? and invitation_accepted_at.blank?
  end

  # clear password reset tokens on password change.
  def update_with_password(*args)
    super.tap do |result|
      if result and password_was_changed?
        reset_reset_password_tokens!
      end
    end
  end

  def site_for_hostname(hostname)
    host = hostname.downcase
    sites.where(hostname: host).first ||
      sites.where("? = ANY(aliases)", host).first
  end

  def self.current
    Bold::current_user
  end

  private

  # send mails via ActiveJob
  def send_devise_notification(email, *args)
    devise_mailer.send(email, self, *args).deliver_later
  end

  # invalidate password reset links after email address change
  def after_confirmation
    reset_reset_password_tokens!
  end

  def reset_reset_password_tokens!
    update_columns reset_password_token: nil, reset_password_sent_at: nil
  end

  def password_was_changed?
    previous_changes['encrypted_password'].present?
  end

end
