class Admin::InvitationsController < Admin::BaseController

  def new
    @friend_invite = FriendInvite.new
  end

  def create
    @friend_invite = FriendInvite.new params[:friend_invite]
    @friend_invite.extract_emails
    @friend_invite.filter_blank_and_init!

    if @friend_invite.valid?
      @friend_invite.enqueue_invites current_user

      flash[:notice] = "Invites will be sent shortly!"

      redirect_to new_admin_invitation_path
    else
      unless @friend_invite.has_invites?
        @friend_invite.errors.clear
        flash[:alert] = "Uhoh, you didn't specify anyone?"
        redirect_to new_admin_invitation_path
      else
        render :new
      end
    end
  end
end