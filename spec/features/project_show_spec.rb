require 'rails_helper'

describe 'Project show page' do

  let(:project) do
    project = Project.new name: "An example project"
    team = project.build_team user_name: 'test-team'
    project.team.members.new user_id: user.id
    project.save
    project
  end

  let(:user) do
    User.create email: 'email@email.com', email_confirmation: 'email@email.com', password: 'password'
  end

  it 'has the name of the project' do
    visit "/" + project.uri

    within ".project-title" do
      expect(page).to have_content "An example project"
    end
  end
end