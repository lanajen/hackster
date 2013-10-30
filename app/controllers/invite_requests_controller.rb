class InviteRequestsController < ApplicationController
  before_filter :require_no_authentication

  # GET /invite_requests/new
  def new
    @invite_request = InviteRequest.new
    @invite_request.build_project
    @invite_request.project.build_logo
  end

  # POST /invite_requests
  def create
    @invite_request = InviteRequest.new(params[:invite_request])
    project = @invite_request.project
    if project.name.blank? and project.one_liner.blank? and project.logo.file.blank?
      project.destroy
    elsif project
      project.force_basic_validation!
      project.logo.disallow_blank_file!
      project.private = true
    end

    if @invite_request.save
      BaseMailer.enqueue_email 'invite_request_notification', { context_type: :invite_request_notification, context_id: @invite_request.id }
      BaseMailer.enqueue_email 'invite_request_confirmation', { context_type: :invite_request, context_id: @invite_request.id }
      redirect_to root_url, notice: "Thanks! We'll be in touch soon."
    else
      render action: "new"
    end
  end
end
