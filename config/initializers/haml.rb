require 'haml'
Haml::Template.options[:ugly] = Rails.env.production?
