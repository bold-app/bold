require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include BoldIntegrationTestHelpers

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  setup do
    setup_bold
  end
end
