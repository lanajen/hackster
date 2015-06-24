require 'rails_helper'

describe 'User sign up' do
  it 'user can sign up' do
    Capybara.app_host = "http://#{APP_CONFIG['full_host']}:#{APP_CONFIG['default_port']}"
    Capybara.server_port = APP_CONFIG['default_port']
    visit new_user_registration_path
    within "#new-user-signup" do
      fill_in "user_email", with: "newuser@example.com"
      fill_in "user_email_confirmation", with: "newuser@example.com"
      fill_in "user_password", with: "newuser@example.com"
      click_on "Create my account"
    end

    expect(page).to have_selector '#user-nav-face'
  end
end