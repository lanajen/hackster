require 'rails_helper'

RSpec.describe 'Project creation' do
  let!(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_user(user)
  end

  scenario 'user creates a new project', :js => true do
    visit "/#{user.user_name}"
    click_on('New project')

    name = 'A Test Project'
    fill_in 'base_article_name', with: name
    click_on('Continue')

    within '.alert-success' do
      expect(page).to have_content("#{name} was successfully created.")
    end
  end
end