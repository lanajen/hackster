require 'rails_helper'

RSpec.describe 'platform #show view' do

  context 'when a platform exists' do
    let!(:platform) { FactoryGirl.create(:platform) }

    it 'has a page with an endpoint that matches its name' do
      visit "/#{platform.user_name}"
      expect(page).to have_content(platform.full_name)
    end
  end

  context 'when a platform has parts', :js => true do
    let(:parts_length) { rand(1..3) }
    let!(:parts) { FactoryGirl.create_list(:part, parts_length, :hardware) }
    let!(:platform) { FactoryGirl.create(:platform, :with_parts, parts: parts) }

    before(:each) do
      visit "/#{platform.user_name}"
    end

    it 'has a products count incremented by parts length' do
      expect(page).to have_content("Products#{parts_length}")
    end

    it 'has a link that routes to user_name/products' do
      first(:xpath, "//a[@href='/#{platform.user_name}/products']").click
      expect(page).to have_selector('.part-box', count: parts_length)
    end
  end
end

RSpec.describe 'platform/products view' do
  let!(:user) { FactoryGirl.create(:user) }

  context 'when a platform has parts with js running', :js => true do
    let(:parts_length) { rand(1..3) }
    let!(:parts) { FactoryGirl.create_list(:part, parts_length, :hardware) }
    let!(:platform) { FactoryGirl.create(:platform, :with_parts, parts: parts) }

    before(:each) do
      login_user(user)
      visit "/#{platform.user_name}/products"
    end

    it 'has a following button in the nav' do
      within ".section-nav" do
        expect(page).to have_content("Follow #{platform.full_name}")
      end
    end

    it 'shows a now followed prompt when following button is clicked' do
      within '.follow-container' do
        find('.follow-button').click
      end
      expect(page).to have_selector('#followed_share_prompt')
    end

    it 'has an "I own it" button' do
      expect(first('.part-box')).to have_content "I own it!"
    end

    it 'adds part to toolbox when "I own it" is clicked' do
      first_box = first('div.part-box')

      within first_box do
        find('.follow-button').click
        expect(page).to have_content "In toolbox!"
      end
    end
  end
end