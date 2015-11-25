require 'rails_helper'

RSpec.describe 'Project show page', type: :feature do
  let!(:user) { FactoryGirl.create(:user).tap { |u| u.confirmed_at = Time.now; u.save! } }

  let!(:project) do
    project = FactoryGirl.build(:project, name: 'An example project')
    team = project.build_team user_name: 'test-team'
    project.team.members.new user_id: user.id
    project.pryvate = false
    project.workflow_state = 'approved'
    project.save
    project
  end

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

  it 'tracks respects for the project' do
    login_as(user, :scope => :user, :run_callbacks => false)
    # expect(page).to have_selector '#user-nav-face'


    visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
    within "#home" do
      expect(page).to have_content "0 respect"
    end

    within ".mg-10" do
      expect(page).to have_content "Respect project"
      page.find('.respect-button').click
    end

    # visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
    # within "#home" do
    #   expect(page).to have_content "1 respect"
    # end
  end

  context 'when there are two projects' do
    let!(:other_project) do
      project = FactoryGirl.build(:project, name: 'An example project')
      team = project.build_team user_name: 'test-team'
      project.team.members.new user_id: user.id
      project.private = false
      project.workflow_state = 'approved'
      project.save
      project
    end

    it 'has a navigation tab to the next project' do
      visit project_path(project_slug: project.slug_hid, user_name: user.user_name)
      click_link_or_button 'Next project'
      expect(page).to have_content 'Respect project'
    end
  end
end
