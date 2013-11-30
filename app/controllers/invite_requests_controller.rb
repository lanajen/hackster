class InviteRequestsController < ApplicationController
  # before_filter :require_no_authentication
  before_filter :validate_security_token, only: [:edit, :update]
  # skip_before_filter :authenticate_user!
  layout 'splash'

  def new
    redirect_to home_url and return if user_signed_in?
    @invite_request = InviteRequest.new
  end

  def create
    @invite_request = InviteRequest.new(params[:invite_request])

    if @invite_request.save
      BaseMailer.enqueue_email 'invite_request_notification', { context_type: :invite_request_notification, context_id: @invite_request.id }
      BaseMailer.enqueue_email 'invite_request_confirmation', { context_type: :invite_request, context_id: @invite_request.id }
      redirect_to edit_invite_request_path(@invite_request)

      track_user @invite_request.to_tracker, @invite_request
      track_event 'Requested an invite', { email: @invite_request.email }, @invite_request
    else
      render action: "new"
    end
  end

  def edit
    redirect_to home_url and return if user_signed_in?
    @invite_request.build_project unless @invite_request.project
    @invite_request.project.build_logo unless @invite_request.project.logo
  end

  def update
    @invite_request.assign_attributes(params[:invite_request])

    @invite_request.project.force_basic_validation!
    @invite_request.project.logo.disallow_blank_file!
    @invite_request.project.private = true

    if @invite_request.save
      redirect_to root_url, notice: "That project looks badass! We'll be in touch soon."

      track_event 'Created invite req project', { project_id: @invite_request.project.id, project_name: @invite_request.project.name }, @invite_request
    else
      render action: "edit"
    end
  end

  private
    def validate_security_token
      @invite_request = InviteRequest.find params[:id]
      redirect_to root_url and return unless @invite_request.security_token_valid? params[:id]
    end
end