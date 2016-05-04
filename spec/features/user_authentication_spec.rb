require 'rails_helper'

RSpec.describe 'User authentication', focus: false do
  scenario 'user signs up' do
    visit new_user_registration_path

    within "#new-user-signup" do
      fill_in "user_email", with: "newuser@example.com"
      fill_in "user_email_confirmation", with: "newuser@example.com"
      fill_in "user_password", with: "newuser@example.com"
      click_on "Create my account"
    end

    expect(current_path).to eql(user_after_registration_path)
    # NOTE: For some reason #user-nav-face is not found if :js is enabled ?
    expect(page).to have_selector '#user-nav-face'
  end

  scenario 'user logs in with invalid password', :js do
    user = create :user
    page.driver.browser.manage.window.maximize # make 'Log in' visible

    visit root_path
    click_on 'Log in'
    within '#login-form' do
      fill_in "user_email", with: user.email
      fill_in "user_password", with: "invalidPassword"
      click_on 'Log into my account'
    end

    expect(current_path).to eql(new_user_session_path)
  end

  scenario 'user logs in with valid password', :js do
    user = create :user
    page.driver.browser.manage.window.maximize # make 'Log in' visible

    visit root_path
    click_on 'Log in'
    within '#login-form' do
      fill_in "user_email", with: user.email
      fill_in "user_password", with: user.password
      click_on 'Log into my account'
    end

    # If user's toolbox_shown attribute is false, redirect here:
    expect(current_path).to eql(user_toolbox_path)
    expect(page).to have_selector '#user-nav-face'
  end
end
