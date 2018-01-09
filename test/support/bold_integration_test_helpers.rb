
module BoldIntegrationTestHelpers

  def setup_bold
    @admin = create :confirmed_admin
    @site_admin = create :confirmed_user
    @user = create :confirmed_user

    @theme_name = if respond_to?(:theme_name)
                    theme_name
                  else
                    ENV['BOLD_THEME'] || 'test'
                  end
    @site = Site.find_by_hostname('127.0.0.1') || create( :site, hostname: '127.0.0.1', theme_name: @theme_name )

    @site.add_user! @user
    @site.add_user! @site_admin, :manager
  end

  def teardown_bold
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


