class Users::InvitationsController < Devise::InvitationsController
  before_filter :authenticate_inviter!, only: []
  before_filter :require_authentication, only: [:new, :create]
  before_filter :require_no_authentication, only: [:edit, :update, :invite]
  before_filter :configure_permitted_parameters, only: [:create, :update]

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

      # if current_inviter.invitation_limit != 0
      #   remaining_msg = "You still have #{view_context.pluralize(current_inviter.invitation_limit, 'invitation')} left."
      # else
      #   remaining_msg = "You've used all your invitations, good job!"
      # end
      flash[:notice] = "Cool, you just invited #{view_context.pluralize(invited.size, 'friend')}!"

      respond_with @friend_invite, :location => after_invite_path_for(@friend_invite)

      track_event 'Sent invites', { count: invited.size }
      invited.each do |user|
        track_event 'Invited', { by: current_user.id, is_admin: current_user.is?(:admin) }, user
      end

    else
      unless @friend_invite.has_invites?
        @friend_invite.errors.clear
        flash[:alert] = "Uhoh, you didn't specify anyone?"
        respond_with @friend_invite, :location => new_user_invitation_path
      else
        @invite_limit = current_user.invitation_limit
        respond_with_navigational(@friend_invite) { render :new }
      end
    end
  end

  def edit
    if session['devise.invitation_token']
      params[:invitation_token] ||= session['devise.invitation_token']
    else
      session['devise.invitation_token'] = params[:invitation_token]
    end

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
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:invite) do |u|
        u.permit(:email)
      end
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(:user_name, :email, :password, :invitation_code, :invitation_token)
      end
    end

    def after_invite_path_for(resource)
      new_user_invitation_path
    end

    def after_accept_path_for(resource)
      user_after_registration_path
    end
end