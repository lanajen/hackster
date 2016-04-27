# !! WARNING !!
# These tests read from and write to dev database instead of test database.
# I believe this is due to the mousercontest/www subdomain difference.
# Fixing this would require config on Capybara. I do not think these tests are worth it.
# See link below for more:
# http://stackoverflow.com/questions/6536503/capybara-with-subdomains-default-host
# These tests assume presence of two users:
# 1:
# email is testuser@example.com
# and
# password is password
# 2:
# user registered via Github with creds in ENV
# - @ZacharyRSmith 4.15.16
require 'rails_helper'

RSpec.describe 'Mouser contest authentication flow:', :js, focus: false do
  let!(:login_link_text) { 'Log In' }
  let!(:signup_link_text) { 'Sign Up' }
  let!(:splash_page_url) { 'http://mousercontest.localhost.local:5000/' }

  after(:each) do |test|
    unless test.metadata[:skip_after]
      logout_user
    end
  end

  # TODO ? test signing up with invalid then valid info
  scenario 'user signs up with valid information on splash page' do
    # !! WARNING !! This test will fail if a "newuser@example.com" user already exists
    visit splash_page_url
    click_on signup_link_text
    within "#new-user-signup" do
      fill_in "user_email", with: "newuser@example.com"
      fill_in "user_email_confirmation", with: "newuser@example.com"
      fill_in "user_password", with: "newuser@example.com"
      click_on "Create my account"
    end

    expect(on_splash_page?).to eql(true)
    expect(page).not_to have_selector(:link_or_button, signup_link_text)
  end

  scenario 'user logs in with invalid password then valid password' do
    # !! WARNING !! See note at top of file
    visit splash_page_url
    click_on login_link_text
    within '#login-form' do
      fill_in "user_email", with: 'testuser@example.com'
      fill_in "user_password", with: 'invalidPassword'
      click_on 'Log into my account'
    end
    within '#login-form' do
      fill_in "user_email", with: 'testuser@example.com'
      fill_in "user_password", with: 'password'
      click_on 'Log into my account'
    end

    expect(on_splash_page?).to eql(true)
    expect(page).not_to have_selector(:link_or_button, login_link_text)
  end

  scenario 'user logs in with valid password' do
    # !! WARNING !! See note at top of file
    visit splash_page_url
    click_on login_link_text
    within '#login-form' do
      fill_in "user_email", with: 'testuser@example.com'
      fill_in "user_password", with: 'password'
      click_on 'Log into my account'
    end

    expect(on_splash_page?).to eql(true)
    expect(page).not_to have_selector(:link_or_button, login_link_text)
  end

  scenario 'user logs in with oauth' do
    # !! WARNING !! See note at top of file
    visit splash_page_url
    click_on login_link_text
    page.find(:css, ".zocial-block.github").click
    within 'form' do
      fill_in 'login_field', with: ENV['GITHUB_EMAIL']
      fill_in 'password', with: ENV['GITHUB_PASSWORD']
      click_on 'Sign in'
    end

    expect(on_splash_page?).to eql(true)
    expect(page).not_to have_selector(:link_or_button, login_link_text)
  end

  scenario 'user logs out on vendor page', :skip_after do
    # !! WARNING !! See note at top of file
    visit splash_page_url
    click_on login_link_text
    within '#login-form' do
      fill_in "user_email", with: 'testuser@example.com'
      fill_in "user_password", with: 'password'
      click_on 'Log into my account'
    end

    expect(on_splash_page?).to eql(true)
    expect(page).not_to have_selector(:link_or_button, login_link_text)

    visit "#{splash_page_url}intel"
    click_on 'Log Out'

    expect(on_splash_page?).to eql(true)
    expect(page).to have_selector(:link_or_button, login_link_text)
  end
end

def logout_user
  visit splash_page_url unless on_splash_page?
  click_on 'Log Out'

  expect(on_splash_page?).to eql(true)
  expect(page).to have_selector(:link_or_button, login_link_text)
end

def on_splash_page?
  # Use expect instead of conditionals to get better err reporting
  expect(current_host).to include('mousercontest')
  expect(current_path).to eql('/')
  true
end
