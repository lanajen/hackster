require 'rails_helper'

describe 'Project show page' do
  let(:user) { FactoryGirl.create(:user) }

  # let(:platform) { FactoryGirl.create(:platform) }
  # let(:project_collection) { FactoryGirl.create(:project_collection, projects: [ project ], collectable: platform )}

  let(:project) do
    project = FactoryGirl.build(:project, name: 'An example project')
    team = project.build_team user_name: 'test-team'
    project.team.members.new user_id: user.id
    project.private = false
    project.workflow_state = 'approved'
    project.save
    project
  end

  it 'has the name of the project' do
    visit "/" + project.uri

    within ".project-title" do
      expect(page).to have_content "An example project"
    end
  end

  context 'when there are two projects' do
    # let!(:another_project) { FactoryGirl.create(:project) }

    it 'has a navigation tab to the next project' do
      visit '/' + project.uri
      p current_url
      Project.all.each { |thing| p thing }
      click_link_or_button 'Next project'
      expect(page).to have_content 'Respect project'
    end
  end
end
