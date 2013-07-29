class InviteRequestsController < ApplicationController
  before_filter :require_no_authentication

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
      redirect_to root_url, notice: "Thanks! We'll be in touch soon."
    else
      render action: "new"
    end
  end
end
