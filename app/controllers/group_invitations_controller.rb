class GroupInvitationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :load_and_authorize_invitable, only: [:new, :create]
  before_filter :load_invitable, except: [:new, :create]
  respond_to :html
  layout :set_layout

  def index
    redirect_to group_path(@group), alert: 'Invalid invitation token' and return unless token_valid?
    redirect_to group_path(@group) and return if user_signed_in? and current_user.is_member?(@group)
  end

  def new
  end

  def create
    if params[:emails].present?
      @invitable.invite_with_emails params[:emails], current_user
      flash[:notice] = "Your invitations are on their way!"
    else
      flash[:alert] = "Please specify at least one email to invite."
    end
    redirect_to group_path(@invitable)
  end

  def accept
    @group = Group.find(params[:group_id])
    token_valid? or authorize! :join, @group
    if member = current_user.is_member?(@group)
      if member.invitation_pending?
        member.accept_invitation!
        flash[:notice] = "Welcome to #{@group.name}!"
      else
        flash[:notice] = "You're already a member of this group."
      end
      redirect_to group_path(@group)
    else
      if token_valid? or @group.access_level == 'anyone'
        m = @group.members.create user_id: current_user.id
        m.group_roles = [params[:role]] if params[:role] and params[:role].in? m.class.group_roles
        m.permission.action = params[:permission] if token_valid? and params[:permission] and params[:permission].in? Permission::ACTIONS.values
        m.save if m.changed? or m.permission.changed?
        redirect_to group_path(@group), notice: "Welcome to #{@group.name}!"
      else
        redirect_to root_path, alert: "We couldn't find an invitation for this group."
      end
    end
  end

  private

    def load_invitable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @invitable = $1.classify.constantize.find(value)
          @model_name = @invitable.class.model_name.to_s.underscore
          instance_variable_set "@#{@model_name}", @invitable
          instance_variable_set "@#{@invitable.class.name.to_s.underscore}", @invitable
          break
        end
      end
    end

    def load_and_authorize_invitable
      load_invitable
      authorize! :manage, @invitable if @invitable
    end

    def set_layout
      case @invitable
      when Tech
        'tech'
      else
        @model_name
      end
    end

    def token_valid?
      @group.invitation_token == params[:token]
    end
end