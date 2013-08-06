class Admin::InviteCodesController < Admin::BaseController
  load_resource
  respond_to :html

  def index
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @invite_code.save
        format.html { redirect_to admin_invite_codes_url, notice: 'Invite code was successfully created.' }
        format.json { render json: @invite_code, status: :created, location: @invite_code }
      else
        format.html { render action: "new" }
        format.json { render json: @invite_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @invite_code.update_attributes(params[:invite_code])
        format.html { redirect_to admin_invite_codes_url, notice: 'Invite code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @invite_code.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invite_code.destroy

    respond_to do |format|
      format.html { redirect_to admin_invite_codes_url }
      format.json { head :no_content }
    end
  end
end
