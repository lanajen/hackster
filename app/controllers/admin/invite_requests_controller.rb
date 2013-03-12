class Admin::InviteRequestsController < Admin::BaseController
  # GET /invite_requests
  # GET /invite_requests.json
  def index
    @invite_requests = InviteRequest.order(:id).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invite_requests }
    end
  end

  # GET /invite_requests/1/edit
  def edit
    @invite_request = InviteRequest.find(params[:id])
  end

  # PUT /invite_requests/1
  # PUT /invite_requests/1.json
  def update
    @invite_request = InviteRequest.find(params[:id])

    respond_to do |format|
      if @invite_request.update_attributes(params[:invite_request])
        format.html { redirect_to admin_invite_requests_url, notice: 'InviteRequest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @invite_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invite_requests/1
  # DELETE /invite_requests/1.json
  def destroy
    @invite_request = InviteRequest.find(params[:id])
    @invite_request.destroy

    respond_to do |format|
      format.html { redirect_to admin_invite_requests_url(:page => params[:page]) }
      format.json { head :no_content }
    end
  end

  def send_invite
    @invite_request = InviteRequest.find(params[:id])
    if @invite_request.invite_sent and User.find_by_email(@invite_request.email).invitation_accepted_at.present?
      flash[:alert] = "#{@invite_request.email} is already subscribed. Nothing sent."
    elsif @invite_request.send_invite!
      flash[:notice] = "#{@invite_request.email} has been sent an invite."
    else
      flash[:alert] = "Something went wrong while inviting #{@invite_request.email}."
    end
    redirect_to admin_invite_requests_url(:page => params[:page])
  end
end
