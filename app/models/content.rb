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
class Content < ActiveRecord::Base
  include SiteModel
  include HasPermalink
  include Taggable

  # once published, content may have staged, not yet published changes:
  include Draftable

  include Markdown

  validates :template, presence: true
  validates :author,   presence: true
  validates :title,    presence: true

  validate :check_template_existence

  belongs_to :author, class_name: 'User'

  has_many :request_logs, as: :resource

  store_accessor :meta, :meta_title
  store_accessor :meta, :meta_description

  # any content is either a draft or published, or scheduled to be published
  # in the future.
  enum status: %i(draft scheduled published)
  after_initialize do |r|
    r.status ||= :draft
    r.template_field_values ||= {}
  end
  before_validation do |r|
    r.slug.sub! %r{\A/}, ''
    r.body ||= ''
  end

  before_validation :set_author, on: :create

  scope :drafts, ->{
    includes(:draft).
    where("#{Content.table_name}.status = :draft OR #{Draft.table_name}.id IS NOT NULL",
          draft: Content.statuses[:draft]).
    references(Draft.table_name).
    order("COALESCE(#{Draft.table_name}.updated_at, #{Content.table_name}.updated_at) DESC")
  }
  scope :by_last_published_at, ->{ order 'COALESCE(last_update, post_date) DESC' }

  scope :authored_by, ->(name){
    joins(:author).where("lower(users.name) = ?", name.to_s.unicode_downcase)
  }


  #
  # Destruction handling
  #

  scope :alive, ->{ where deleted_at: nil }

  # true if not deleted
  def alive?; !deleted? end

  # true if deleted
  def deleted?
    deleted_at.present?
  end

   #marks this content as deleted and destroys the permalink
  def delete
    return false if homepage?
    transaction do
      unpublish if published?
      update_attributes deleted_at: Time.now
      permalink&.destroy
      # FIXME need to cleanup any redirects pointing here as well. problem is,
      # redirects just have a location(string)
    end
  end


  #
  # Search
  #

  Bold::Search::ContentIndexer.setup self

  def fulltext_searchable?
    get_template.fulltext_searchable?
  end

  def template_field_value?(field_name)
    template_field_values[field_name.to_s].present?
  end

  def template_field_value(field_name)
    template_field_values[field_name.to_s]
  end

  def template_fields_partial
    site.theme.template_path "fields/#{template}"
  end

  def has_template_fields?
    get_template.fields?
  end

  def last_published_at
    last_update || post_date
  end

  def commentable?; false end

  # does the current template show body content?
  def has_body?
    get_template.has_body?
  end

  def homepage?
    site.homepage_id == id
  end

  def publish!(create_permalink: true)
    return true unless changed? || draft? || scheduled?
    old_attributes = attributes.slice 'status', 'post_date', 'last_update'
    transaction do
      now = Time.zone.now
      if self.post_date && post_date > now
        self.status = :scheduled
        @skip_permalink = true
      else
        self.post_date ||= now
        self.last_update = now unless draft? || scheduled?
        self.status = :published
        @skip_permalink = true unless create_permalink
      end
      if save(context: :publish)
        if scheduled?
          PublisherJob.set(wait_until: post_date).perform_later(self)
        end
        true
      else
        self.attributes = old_attributes
        false
      end
    end
  end

  def unpublish
    update_attributes status: :draft, last_update: nil
  end

  # true if content was updated after it has been initially published
  def has_update?
    last_update && post_date && last_update > post_date
  end

  def post_date_str
    I18n.l post_date, format: :bold_ymdt if post_date
  end
  def post_date_str=(str)
    self.post_date = Chronic.parse(str)
  end

  # (drafted) title
  def current_title
    has_draft? && draft.drafted_changes['title'].present? ? draft.drafted_changes['title'] : title
  end

  # post or page?
  def kind
    self.class.name.split('::').last.underscore
  end

  def title_html
    md_render_content self, title
  end

  def body_html
    md_render_content self
  end

  def get_template
    @template ||= site.theme.template(template)
  end

  def check_template_existence
    unless get_template.present?
      errors.add :template, :invalid
    end
  end

  def publishing_year
    (post_date || Time.zone.now).year.to_s
  end

  def publishing_month
    "%02d" % (post_date || Time.zone.now).month
  end

  def stats_pageviews
    site.stats_pageviews.where(content_id: id)
  end

  def pageviews(from: nil, to: nil)
    hits = stats_pageviews
    hits = hits.since(from) if from
    hits = hits.until(to) if to
    hits
  end

  def hit_count(from: nil, to: nil)
    count_pageviews pageviews(from: from, to: to)
  end

  def hit_count_by_device_class(from: nil, to: nil)
    count_pageviews(
      pageviews(from: from, to: to).
      includes(:stats_visit).
      references(:stats_visit).
      group('stats_visits.mobile')
    ).tap do |hits|
      hits[:mobile]  = hits.delete true
      hits[:desktop] = hits.delete false
    end
  end


  private

  def count_pageviews(scope)
    scope.count 'distinct(content_id, stats_visit_id)'
  end

  def slug_attribute
    title
  end

  def set_author
    self.author ||= User.current
  end


  class << self
    def [](slug)
      if content = Site.current.contents.published.find_by_slug(slug)
        content.decorate
      end
    end
  end

end
