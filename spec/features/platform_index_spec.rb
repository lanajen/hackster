require 'rails_helper'

RSpec.describe 'platform #index view', type: :feature do
  let!(:platform) { FactoryGirl.create(:platform) }
  let!(:user) { FactoryGirl.create(:user) }

  context 'when a platform exists' do
    before(:each) do
      login_as(user)
      visit '/platforms'
    end

    it 'is displayed on /platforms' do
      expect(page).to have_content(platform.full_name)
    end

    it 'has a unique route by platform name' do
      first(:xpath, "//a[@href='/#{platform.user_name}']").click

      within ".top-banner" do
        expect(page).to have_content(platform.full_name)
      end
    end
  end
end