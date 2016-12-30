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
class Site < ActiveRecord::Base
  include HasTimezone

  scope :by_name, ->{ order('name ASC') }

  has_many :assets,       dependent: :destroy
  has_many :contents,     dependent: :destroy
  has_many :request_logs
  has_many :stats_pageviews
  has_many :stats_visits
  has_many :tags
  has_many :unread_items

  # has_many with on_delete: :cascade
  has_many :permalinks
  has_many :extension_configs
  has_many :site_users
  has_many :visitor_postings
  has_many :navigations, ->{ order(position: :asc) }
  has_many :categories, ->{ order(name: :asc) }

  has_many :users,    through: :site_users

  belongs_to :homepage, class_name: 'Content'

  # the mail_from setting is unused atm, add UI once we need it, i.e. once
  # sites send emails for whatever reason
  CONFIG_ATTRIBUTES = %i(
    adaptive_images
    akismet_key
    author_page_id
    archive_page_id
    body_end_snippet
    body_start_snippet
    category_page_id
    default_image_link_version
    default_image_version
    default_locale
    detect_user_locale
    error_page_id
    favicon_id
    honor_donottrack
    html_head_snippet
    logo_id
    mail_from
    notfound_page_id
    post_comments
    search_page_id
    site_css
    site_js
    tag_page_id
    theme_name
    time_zone_name
    tsearch_config
    twitter_handle
    url_scheme
  )

  CONFIG_ATTRIBUTES.each do |attribute|
    store_accessor :config, attribute
  end


  validates :name, presence: true
  validates :theme_name, presence: true
  validates :hostname, presence: true, format: { with: /\A[[:alnum:]\-\.]+\z/ }
  validate :ensure_hostname_uniqueness
  validate :ensure_alias_uniqueness

  before_validation do
    self.hostname = ::Site.normalize_hostname hostname
  end

  before_create :init_defaults

  def self.for_hostname(host)
    host = normalize_hostname host
    where(hostname: host).first || where("aliases @> ARRAY[?]::varchar[]", host).first
  end

  # Returns the currently active site.
  #
  # alias for ::Bold.current_site
  def self.current
    Bold.current_site
  end

  def self.other_sites
    if Bold.current_user
      Bold.current_user.sites.where "#{table_name}.id <> ?", ::Bold.current_site.id
    else
      []
    end
  end

  def spam
    @spam ||= SiteSpam.new self
  end

  def unread?(item, user: Bold.current_user)
    unread_items.for(user).for(item).any?
  end

  def alias_string
    (aliases || []).join ' '
  end

  def alias_string=(s)
    self.aliases = s.split(/[, ]/).map do |s|
      Site.normalize_hostname s
    end.reject(&:blank?)
  end

  def theme
    Bold::Theme[theme_name]
  end

  def theme_config
    extension_configs.themes.where(name: theme_name).first ||
      create_theme_config
  end

  def plugin_config(id)
    extension_configs.plugins.where(name: id).first || create_plugin_config(id)
  end

  # returns the plugin configurations currently enabled for this site
  def plugin_configs
    extension_configs.plugins.all.select(&:enabled?)
  end
  # TODO deprecate
  alias plugins plugin_configs

  def extension_enabled?(name)
    extension_configs.where(name: name).detect(&:enabled?).present?
  end
  alias plugin_enabled? extension_enabled?

  def enable_theme!(name)
    name = name.to_s
    transaction do
      update_attribute :theme_name, name
      raise 'theme change failed' unless theme.present? && theme.id.to_s == name
    end
  end

  # there can only be one theme enabled at a time
  def theme_enabled?(id)
    theme_name == id.to_s
  end

  def enable_plugin!(name)
    plugin_config(name).enable!
  end

  def disable_plugin!(name)
    plugin_config(name).disable!
  end

  def auto_approve_comments?
    'enabled' == post_comments
  end

  COMMENTABLE_STATES = %w( with_approval enabled )
  def comments_enabled?
    COMMENTABLE_STATES.include? post_comments
  end

  # these are used in the backend
  DEFAULT_IMAGE_VERSIONS = [
    { name: :bold_thumb,    height: 240, quality: 60 },
    { name: :bold_thumb_sq, width: 400, height: 400, crop: true, quality: 60 },
    { name: :bold_preview,    width: 600, quality: 60 },
  ].map{|parameters| Bold::ImageVersion.new parameters }

  # available image versions under the current theme
  def image_versions
    if theme.image_versions.any?
      theme.image_versions.values
    else
      DEFAULT_IMAGE_VERSIONS
    end
  end

  def image_version(name)
    name = name.to_s
    image_versions.detect{|v| v.name.to_s == name}
  end

  def has_image_version?(name)
    name.to_s == 'original' or image_version(name).present?
  end

  def authors
    users.where(id: author_ids)
  end

  def author_ids
    content_pages.distinct.pluck(:author_id)
  end

  def pages
    Page.where site_id: id
  end

  # all pages that are not 'special' pages. this excludes e.g. author, tag and
  # category pages, the home page and 'file not found'.
  def content_pages
    pages.
      where(template: theme.content_templates.map(&:name)).
      where('id NOT in (?)', special_page_ids)
  end

  def posts
    Post.where site_id: id
  end

  SPECIAL_PAGES = %w(notfound error tag category author archive search)
  SPECIAL_PAGES.each do |page_name|
    define_method "#{page_name}_page" do
      if page_id = send("#{page_name}_page_id") and page_id.present?
        pages.published.find page_id
      end
    end
  end

  def special_page_ids
    (SPECIAL_PAGES.map{|page_name| send "#{page_name}_page_id"} << homepage_id).select(&:present?)
  end

  %i(favicon logo).each do |m|
    define_method m do
      id = send "#{m}_id"
      assets.find id if id.present?
    end
  end

  def external_url(path = '')
    URI.parse('').tap do |u|
      u.host = hostname
      u.scheme = url_scheme
      path = "/#{path}" unless path.to_s.start_with?('/')
      u.path = path
    end.to_s
  end
  alias public_url external_url


  def add_user!(user, role = :editor)
    site_users.create! user: user, manager: (role == :manager) unless user.site_user?(self)
  end

  def available_locales
    theme.locales || []
  end

  def detect_user_locale?
    detect_user_locale.to_s == '1'
  end

  def honor_donottrack?
    honor_donottrack.to_s == '1'
  end

  def adaptive_images?
    adaptive_images.to_s == '1'
  end

  def compute_stats
    transaction do
      StatsPageview.build_pageviews self
    end
  end

  def recompute_stats
    transaction do
      StatsVisit.delete_all(site_id: id) # cascade-deletes all pageviews as well
      request_logs.update_all processed: false, device_class: nil
      compute_stats
    end
  end

  def comments
    visitor_postings.where type: 'Comment'
  end

  def contact_messages
    visitor_postings.where type: 'ContactMessage'
  end

  def store_backup!
    ExportSite.call self
  end

  private

  def init_defaults
    self.time_zone_name = Time.zone.name
    self.theme_name ||= 'none'
    self.tsearch_config ||= 'bold_english'
    self.adaptive_images ||= '1'
    create_theme_config
  end

  def create_theme_config
    configure_extension theme_name, ThemeConfig
  end

  def create_plugin_config(plugin_id)
    configure_extension plugin_id, PluginConfig
  end

  def configure_extension(id, kind)
    kind.new(name: id).tap do |cfg|
      unless new_record?
        cfg.site = self
        cfg.save
      end
      self.extension_configs << cfg
    end
  end



  def ensure_hostname_uniqueness
    unless_unique(self.hostname) do
      errors[:hostname] << I18n.t('bold.activerecord.site.hostname_not_unique')
    end
  end

  def ensure_alias_uniqueness
    aliases.each do |a|
      unless_unique(a) do
        errors[:alias_string] << I18n.t('bold.activerecord.site.alias_not_unique', alias: a)
      end
    end
  end

  def unless_unique(hostname, &block)
    if site = Site.for_hostname(hostname)
      block.call if new_record? || site.id != self.id
    end
  end

  def self.normalize_hostname(host)
    host = host.to_s.unicode_downcase
    host.strip!
    return host
  end
end
