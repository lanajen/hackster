require 'rails_helper'

RSpec.describe 'Project #show view', type: :feature do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:project) { FactoryGirl.create(:project, name: 'An example project', user: user) }

  it 'tracks views for the project' do
    login_as(user)

    expect {
      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
    }.to change(ImpressionistQueue.jobs, :size).by(1)

    within ".project-title" do
      expect(page).to have_content "An example project"
    end

    within "#home" do
      expect(page).to have_content "0 views"
    end

    ImpressionistQueue.drain
    visit project_path(project_slug: project.slug_hid, user_name: user.user_name)

    within "#home" do
      expect(page).to have_content "1 view"
    end
  end

  context 'when there are two projects' do
    let!(:other_project) { FactoryGirl.create(:project, name: 'Another example project', user: user) }

    it 'has a navigation tab to the next project' do
      visit project_path(project_slug: other_project.slug_hid, user_name: user.user_name)
      click_link_or_button 'Next project'
      expect(page).to have_content 'Respect project'
      within ".project-title" do
        expect(page).to have_content "Another example project"
      end
    end
  end

  context 'when a user visits another users project' do
    let!(:other_user) { FactoryGirl.create(:user) }

    before(:each) do
      login_as(other_user)
    end

    it 'initially has 0 respect' do
      visit project_path(project_slug: project.slug_hid, user_name: other_user.user_name)

      within '#home' do
        expect(page).to have_content('0 respects');
      end
    end

    it 'has a respect button that increments respect', :js => true do
      worker = BaseArticleObserverWorker.new

      visit project_path(project_slug: project.slug_hid, user_name: other_user.user_name)

      within page.first(:css, '.mg-10') do
        expect(page).to have_content 'Respect project'
        page.find('.respect-button').click
      end

      worker.perform('after_create', project.id)
      visit project_path(project_slug: project.slug_hid, user_name: other_user.user_name)

      within '#home' do
        expect(page).to have_content('1 RESPECT');
      end
    end
  end

  context 'when a platform is associated by a project_collection' do
    let!(:platform) { FactoryGirl.create(:platform) }
    let!(:collection) { FactoryGirl.create(:project_collection, :with_platform, project: project, platform: platform) }

    it('includes the platform in groups') do
      expect(project.groups).to include platform
    end

    it 'displays a known platform as a link' do
      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
      expect(page).to have_link project.groups[0].full_name
    end
  end

  context 'when 3 platforms exist' do
    let!(:collections) { FactoryGirl.create_list(:project_collection, 3, :with_platform, project: project) }

    it('has 3 groups in project.groups') do
      expect(project.groups.size).to eq(3)
    end

    it('displays links for each group by full_name') do
      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
      project.groups.each do |group|
        expect(page).to have_link group.full_name
      end
    end
  end

  context 'when the project has hardware parts' do
    let!(:part) { FactoryGirl.create(:part, :hardware) }
    let!(:part_join) { FactoryGirl.create(:part_join, part: part, project: project) }

    before(:each) do
      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
    end

    it 'correctly lists Hardware Part under components and supplies' do
      within '#components' do
        expect(page).to have_content(part.name)
      end
    end

    it 'does not provide a link without an association to platform' do
      within '#components' do
        expect(page).not_to have_link(part.name)
      end
    end

    it 'provides a link when associated with a platform' do

      platform = create(:platform, :with_part, part: part)
      create(:project_collection, :with_platform, project: project, platform: platform)

      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)

      within '#components' do
        expect(page).to have_link(project.parts[0].full_name)
      end
    end
  end
end
