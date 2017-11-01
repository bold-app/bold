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
ENV['RAILS_ENV'] ||= 'test'
$VERBOSE=false
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl_rails'
require 'faker'
require 'mocha/setup'


Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Devise.stretches = 1

#require File.expand_path('../../db/seeds', __FILE__)

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include FactoryGirl::Syntax::Methods
  include BoldHelpers

  MockRequest = ImmutableStruct.new(:remote_ip, :user_agent, :referrer,
                                    :env, :language)

  setup do
    Time.zone = 'UTC'
    Bold.current_user = create :confirmed_admin
  end

  teardown do
    clear_enqueued_jobs
    Bold.current_user = nil
    Bold.current_site = nil
  end

  private

  def publish_page(attributes = {})
    save_content_page attributes, true
  end

  # save_page is taken by capybara
  def save_content_page(attributes = {}, publish = false)
    build(:page, { site: @site }.merge(attributes)).tap do |p|
      r = SaveContent.call p, publish: publish
      assert r.saved?, r.inspect
      p.reload
    end
  end

  def publish_post(attributes = {})
    save_post attributes, true
  end

  def save_post(attributes = {}, publish = false)
    build(:post, { site: @site }.merge(attributes)).tap do |p|
      r = SaveContent.call p, publish: publish
      assert r.saved?, r.inspect
      p.reload
    end
  end

  def create_asset(file = Rack::Test::UploadedFile.new(Rails.root/'test'/'fixtures'/'photo.jpg', 'image/jpeg'))
    CreateAsset.call(@site.assets.build(file: file)).asset
  end

  def create_category(name = 'New category')
    CreateCategory.call({name: name}, site: @site).category
  end

  def create_homepage(site: @site)
    publish_page(title: 'homepage', site: site,
                 template: site.theme.find_template(:homepage).name).tap do |p|
      site.update_attribute :homepage_id, p.id
    end
  end

  def create_special_page(kind, site: @site)
    if tpl = site.theme.find_template(kind)
      publish_page(title: kind.to_s,
                   template: tpl.name).tap do |p|
        site.update_attribute :"#{kind}_page_id", p.id
      end
    end
  end

end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def assert_access_denied
    assert_redirected_to new_user_session_path
  end

  def sign_in(user, scope: :user)
    super user, scope: scope
    ::Bold.current_user = user
  end

  setup do
    @user = create :confirmed_admin
    @site = create :site, theme_name: 'test'
    create_homepage
    create :site_user, user: @user, site: @site, manager: true
    sign_in @user
    request.host = @site.hostname
  end

  teardown do
    Bold.current_site = nil
  end

end

class BoldIntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include FactoryGirl::Syntax::Methods

  setup do
    @admin = create :confirmed_admin
    @site_admin = create :confirmed_user
    @user = create :confirmed_user

    @theme_name = if respond_to?(:theme_name)
                    theme_name
                  else
                    ENV['BOLD_THEME'] || 'test'
                  end
    @site = Site.find_by_hostname('test.host') || create( :site, hostname: 'test.host', theme_name: @theme_name )

    @site.add_user! @user
    @site.add_user! @site_admin, :manager
    set_host @site.hostname
  end

  def teardown
  end

  def login_as(user, pass = 'secret.1', site: nil)
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: pass
    click_button 'Sign in'
    assert !has_content?('Sign in')
    @current_user = user
    if user.admin? || user.sites.many?
      assert_equal '/bold', current_path
      if site
        first(:link, site.name).click
      end
    else
      assert_equal "/bold/sites/#{@site.id}", current_path
    end
  end

  def logout
    find('.navbar-right a.dropdown-toggle').click
    within '.navbar-right' do
      click_link 'Sign out'
    end
    assert has_content?('Sign in')
    assert_equal '/users/sign_in', current_path
  end

  def ensure_on(path)
    if path != current_path
      visit path
    end
  end

  def set_host(host)
    host! host
    Capybara.app_host = "http://" + host
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        active = page.evaluate_script('jQuery.active')
        break if active == 0
      end
    end
  end

  def current_body
    Capybara.current_session.driver.response.body
  end

end

class ThemeIntegrationTest < BoldIntegrationTest

  private


  def has_comment_form?
    fill_in 'comment_body', with: 'lorem'
    fill_in 'comment_body', with: ''
    true
  rescue
    false
  end

end

# make sure the ft search config exists
begin
  ::User.connection.execute Bold::Search.sql_for_language_config 'english'
rescue ActiveRecord::RecordNotUnique
end

