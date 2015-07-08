require 'rails_helper'

describe 'User authentication' do
  scenario 'user signs up' do
    visit new_user_registration_path
    within "#new-user-signup" do
      fill_in "user_email", with: "newuser@example.com"
      fill_in "user_email_confirmation", with: "newuser@example.com"
      fill_in "user_password", with: "newuser@example.com"
      click_on "Create my account"
    end

    expect_user_to_be_logged_in
  end

  scenario 'user logs in', :js do
    user = create :user

    visit root_path
    click_on 'Log in'
    within '#new_user' do
      fill_in "user_email", with: user.email
      fill_in "user_password", with: user.password
      click_on 'Log into my account'
    end

    expect_user_to_be_logged_in
  end

  def expect_user_to_be_logged_in
    expect(page).to have_selector '#user-nav-face'
  end
end