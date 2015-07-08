require 'rails_helper'

describe 'Place order in store' do
  scenario 'places an order for a regular item', :js do
    login
    visit store_path
  end

  def login
    user = create :user

    visit root_path
    click_on 'Log in'
    within '#new_user' do
      fill_in "user_email", with: user.email
      fill_in "user_password", with: user.password
      click_on 'Log into my account'
    end
  end
end