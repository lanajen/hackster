class InviteRequestsController < ApplicationController
#  before_filter :require_no_authentication, :only => [:new, :create]
  skip_before_filter :authenticate_user!
  layout 'splash', only: [:new, :create, :confirm]

  # GET /invite_requests/new
  def new
    @invite_request = InviteRequest.new
  end

  # POST /invite_requests
  def create
    @invite_request = InviteRequest.new(params[:invite_request])

    if @invite_request.save
      BaseMailer.enqueue_email 'invite_request_notification', { context_type: :invite_request_notification, context_id: @invite_request.id }
      BaseMailer.enqueue_email 'invite_request_confirmation', { context_type: :invite_request, context_id: @invite_request.id }
      redirect_to confirm_invite_requests_path
    else
      render action: "new"
    end
  end

  def confirm

  end

  def edit
    @invite_request = InviteRequest.find(params[:id])
  end

  def update
    @invite_request = InviteRequest.find(params[:id])

    if @invite_request.update_attributes(params[:invite_request])
      redirect_to new_invite_request_path, notice: "Thanks again!"
    else
      render action: 'edit'
    end
  end
end
