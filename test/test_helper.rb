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

  setup do
    Time.zone = 'UTC'
    Bold.current_user = create :confirmed_admin
  end

  teardown do
    clear_enqueued_jobs
    Bold.current_user = nil
    Bold.current_site = nil
  end
end

class ActionController::TestCase
  include Devise::TestHelpers

  def assert_access_denied
    assert_redirected_to new_user_session_path
  end

  def sign_in(*args)
    super
    ::Bold.current_user = args.last
  end

  setup do
    @user = create :confirmed_admin
    @site = create :site, theme_name: 'test'
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
    @site = Site.find_by_hostname('test.host') || create( :site, hostname: 'test.host', theme_name: 'test' )
    @site.add_user! @user
    @site.add_user! @site_admin, :manager
    set_host @site.hostname
  end

  def teardown
  end

  def login_as(user, pass = 'secret.1')
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: pass
    click_button 'Sign in'
    assert !has_content?('Sign in')
    @current_user = user
    assert_equal '/bold', current_path
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

  def setup_site(theme)
    parse_theme_structure theme
    @site.destroy if @site
    @site = create :site, hostname: 'test.host', theme_name: theme, post_comments: 'enabled'
    @site.add_user! @user

    if @page_tpl
      @page = create :published_page, title: 'Test Page Title', body: 'test page body', site: @site, template: @page_tpl.key
    end

    if @post_tpl
      @category = create :category, name: 'A Category' if @category_tpl
      @post = create :published_post, title: 'Test Post Title', body: 'test post body', site: @site, template: @post_tpl.key, post_date: Time.local(2015, 02, 05), tag_list: 'foo, "bar baz"', author: @user, category: @category
    end
  end

  def parse_theme_structure(theme)
    @theme = Bold::Theme[theme]
    @homepage_tpl = @theme.homepage_template
    @post_tpl     = @theme.find_template :post, :default
    @page_tpl     = @theme.find_template :page, :default
    @tag_tpl      = @theme.find_template :tag, :post_listing
    @archive_tpl  = @theme.find_template :archive, :post_listing
    @category_tpl = @theme.find_template :category, :post_listing
    @author_tpl   = @theme.find_template :author, :post_listing
    @search_tpl   = @theme.find_template :search, :post_listing
  end

  def check_special_pages(except: [])
    %w(homepage archive_page tag_page author_page category_page notfound_page error_page search_page).each do |p|
      next if except.include? p
      assert @site.send(p).present?, "#{p} not found"
    end
  end

  def check_home_page
    visit '/'
  end

  def check_home_page_and_post
    check_home_page
    if @post
      assert has_content? @post.title
      click_link @post.title
      assert has_content? @post.title
      assert has_content? 'test post body'
      assert_equal "/#{@post.path}", current_path
      if has_comment_form?
        fill_in 'comment_author_name', with: 'John the Comment Tester'
        fill_in 'comment_author_email', with: 'user@host.com'
        fill_in 'comment_body', with: Faker::Lorem::paragraph
        click_on 'comment_submit'
        assert_equal "/#{@post.path}", current_path
        refute has_content? 'John the Comment Tester' # DJ / spam check

        assert c = @site.comments.last
        assert_equal 'John the Comment Tester', c.author_name
        assert c.body.present?
        assert !c.approved?
        c.update_attribute :status, :approved

        visit current_path
        assert has_content? 'John the Comment Tester'
      end
    end
  end

  def check_shows_page
    if @page
      visit '/test-page-title'
      assert has_content? 'Test Page Title'
      assert has_content? 'test page body'
    end
  end

  def check_archive
    if @post
      visit '/2015'
      assert has_content? @post.title
      visit '/2015/02'
      assert has_content? @post.title
      visit '/2014/01'
      refute has_content?(@post.title)
    end
  end

  def check_tags
    if @post
      visit '/foo'
      assert has_content? @post.title
    end
  end

  def check_category
    if @post
      visit '/a-category'
      assert has_content? @post.title
    end
  end

  def check_author_listing
    if @post
      assert_equal @user, @post.author
      visit "/authors/#{URI::escape @admin.name}"
      assert !has_content?(@post.title)
      visit "/authors/#{URI::escape @user.name}"
      assert has_content? @post.title
    end
  end

  def has_comment_form?
    fill_in 'comment_body', with: 'lorem'
    fill_in 'comment_body', with: ''
    true
  rescue
    false
  end

end
