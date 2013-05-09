class ParticipantInvitesController < ApplicationController
  before_filter :load_project
  layout 'project'

  def index
    @project.participant_invites.new if @project.participant_invites.empty?
    @issues = @project.all_issues
  end
end