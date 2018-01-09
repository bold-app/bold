require "application_system_test_case"

class AhoysTest < ApplicationSystemTestCase

  setup do
    create_homepage
    publish_post title: 'hello from site 1', body: 'lorem ipsum'
  end

  test 'should log pageviews' do
    assert_difference 'Visit.count' do
      assert_difference 'Ahoy::Event.count' do
        visit '/'
        sleep 2 # wait for the AJAX call to the ahoy API to complete
      end
    end

    assert_no_difference 'Visit.count' do
      assert_difference 'Ahoy::Event.count' do
        click_on 'hello from site 1'
        sleep 2
      end
    end
  end

end
