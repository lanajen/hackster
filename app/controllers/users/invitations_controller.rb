class Users::InvitationsController < Devise::InvitationsController
  before_filter :authenticate_inviter!, only: []
  before_filter :require_authentication, only: [:new, :create]
  before_filter :require_no_authentication, only: [:edit, :update, :invite]

  def new
    @invite_limit = current_user.invitation_limit
    @friend_invite = FriendInvite.new
    [current_user.invitation_limit, 10].min.times { @friend_invite.users.build }
    super
  end

  def create
    @friend_invite = FriendInvite.new(params[:friend_invite])
    @friend_invite.filter_blank_and_init!

    if @friend_invite.valid?
      invited = @friend_invite.invite_all!(current_inviter)

      if current_inviter.invitation_limit != 0
        remaining_msg = "You still have #{view_context.pluralize(current_inviter.invitation_limit, 'invitation')} left."
      else
        remaining_msg = "You've used all your invitations, good job!"
      end
      flash[:notice] = "Cool, you just invited #{view_context.pluralize(invited.size, 'friend')}! #{remaining_msg}"

      respond_with @friend_invite, :location => after_invite_path_for(@friend_invite)

      track_event 'Sent invites', { count: @friend_invite.users.count }

    else
      unless @friend_invite.has_invites?
        @friend_invite.errors.clear
        flash[:alert] = "Uhoh, you didn't specify anyone?"
        respond_with @friend_invite, :location => new_user_invitation_path
      else
        raise @friend_invite.errors.inspect
        @invite_limit = current_user.invitation_limit
        respond_with_navigational(@friend_invite) { render :new }
      end
    end
  end

  def edit
    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first( :invitation_token => params[:invitation_token] )
      @invitation_token = params[:invitation_token]
      render :edit

      track_alias resource
    else
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

#  def invite
#    self.resource = resource_class.new
#    render :generic_invite
#  end

#  def update
#    if params[resource_name][:invitation_token].present?
#      @invitation_token = params[resource_name][:invitation_token]
#      super
#    else
#      self.resource = resource_class.new(params[resource_name])
#      if invite_code = authenticate_invite_code(params[resource_name][:invitation_code])
#        resource.invite_code_id = invite_code.id
#        if resource.save
#          flash[:notice] = "Cool, just go click on the confirmation link in the email we've just sent you and we're good to go!"
#          respond_with resource, :location => invite_code_path
#        else
#          respond_with_navigational(resource) { render :generic_invite }
#        end
#      else
#        flash[:alert] = "Seems like your invite code is either invalid or expired. Please double check it and try again!"
#        respond_with resource, :location => invite_code_path
#      end
#    end
#  end

  private
    def require_authentication
      redirect_to new_user_session_path, alert: 'This page requires authentication.' unless current_user
    end

  protected
    def after_invite_path_for(resource)
      new_user_invitation_path
    end

    def after_accept_path_for(resource)
      user_after_registration_path
    end
end