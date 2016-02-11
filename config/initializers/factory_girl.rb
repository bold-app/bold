Rails.application.config.generators do |g|
  # generate factories instead of fixtures
  g.test_framework :test_unit, fixture_replacement: :factory_girl
  # do not generate per controller asset stubs
  g.assets false
end
