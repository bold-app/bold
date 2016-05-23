source 'https://rubygems.org'

gem 'nokogiri'
gem 'rails', '5.0.0.rc1'
gem 'rails-i18n', '~> 4.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby

gem 'pg', '~> 0.18.2', platforms: :ruby
gem "activerecord-jdbcpostgresql-adapter", platforms: :jruby

gem 'jquery-rails', '~> 4.0.4'
# gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc


gem 'acts_as_list', github: 'bold-app/acts_as_list'
gem 'akismet', '~> 2.0.0'
gem 'bootstrap-kaminari-views', '0.0.3'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'carrierwave', '~> 0.10'
gem 'chronic', github: 'jkraemer/chronic', branch: 'thread_safe'
gem 'coderay', '~> 1.1.1'
gem 'daemons'
gem 'delayed_job_active_record', '~> 4.0'

# FIXME revert to ~> 4.0.0 once released
gem 'devise', '4.0.0.rc1'
gem 'devise_invitable', github: 'bold-app/devise_invitable', branch: 'bold'

gem 'diffy', '~> 3.0.7'

# FIXME check for an officially Rails 5 compatible version of draper
# gem 'draper', '~> 2.1'
gem 'draper', github: 'bold-app/draper', branch: 'rails5'
gem 'activemodel-serializers-xml', github: 'rails/activemodel-serializers-xml'

gem 'exifr', '~> 1.2'
gem 'http_accept_language', '~> 2.0.5'
gem 'httparty', '~> 0.13.5'
gem 'i18n_language_select', github: 'bold-app/i18n_language_select'
gem 'jquery-fileupload-rails', github: 'bold-app/jquery-fileupload-rails'
#gem 'kaminari', '~> 0.16'
gem 'kaminari', github: 'amatsuda/kaminari'
gem 'memento', '~> 0.4.3', github: 'bold-app/memento'
gem 'mimemagic', '~> 0.3.1'
gem 'mini_magick', '~> 3.0'
gem 'haml-rails', '~> 0.9'
gem 'kramdown', '~> 1.9.0'
gem 'request_store', '~> 1.1'
gem 'safe_shell', '~> 1.0.2'
gem 'simple_form', '~> 3.2.1'
gem 'speakingurl-rails', '~> 8.0'
gem 'stringex', '~> 2.5'
gem 'teambox-icons-rails', github: 'bold-app/teambox-icons-rails'

# device detection libraries. support for any of those is built in, but
# user_agent_parser appears to be most capable:
# The libraries will be tried in the order shown here, the first that's found
# is used.
gem 'user_agent_parser', github: 'bold-app/uap-ruby', submodules: true
#gem 'browser'
#gem 'device_detector'


gem 'valid_email'
gem 'warden', '~> 1.2'
gem 'words_counted', '~> 1.0'
gem 'xmp', github: 'jkraemer/xmp'


group :development, :test do
  gem 'pry-byebug', platforms: :ruby
  gem 'puma'
  gem 'quiet_assets'
  gem 'spring'
  #gem 'yaml_db'
end

group :development do
  gem 'web-console', '~> 2.0', platforms: :ruby
end

group :test do
  gem 'capybara', '~> 2.6.0'
  gem 'connection_pool', '~> 2.1.1'
  gem 'factory_girl_rails', '~> 4.5'
  gem 'faker', '~> 1.4'
  gem 'mocha', '~> 1.1.0'
  gem 'rails-controller-testing'
end

# Some default themes
gem 'bold-theme-casper', github: 'bold-app/bold-theme-casper'
gem 'bold-theme-lean', github: 'bold-app/bold-theme-lean'
gem 'bold-theme-bootstrap', github: 'bold-app/bold-theme-bootstrap'

# plugins
gem 'bold-atom_feed', github: 'bold-app/bold-atom_feed'
gem 'bold-piwik', github: 'bold-app/bold-piwik'

base_dir = Pathname.new(__FILE__).dirname

Dir[base_dir.join('vendor', 'gems', '*')].each do |gem_dir|
  if File.directory? gem_dir
    gem File.basename(gem_dir), path: gem_dir
  end
end

local = base_dir.join('Gemfile.local')
instance_eval IO.read local if File.readable? local

