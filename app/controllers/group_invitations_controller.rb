class GroupInvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_invitable
  respond_to :html
  layout :set_layout

  def new
  end

  def create
    if params[:emails].present?
      @invitable.invite_with_emails params[:emails], current_user
      redirect_to @invitable, notice: "Your invitations are on their way!"
    else
      redirect_to @invitable, alert: "Please specify at least one email to invite."
    end
  end

  def accept
    @group = Group.find(params[:group_id])
    if member = current_user.is_member?(@group)
      if member.invitation_pending?
        member.accept_invitation!
        flash[:notice] = "Welcome to #{@group.name}!"
      else
        flash[:notice] = "You're already a member of this group."
      end
      redirect_to @group
    else
      redirect_to root_path, alert: "We couldn't find an invitation for this group."
    end
  end

  private
    def load_and_authorize_invitable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @invitable = $1.classify.constantize.find(value)
          @model_name = @invitable.class.model_name.to_s.underscore
          instance_variable_set "@#{@model_name}", @invitable
          authorize! :manage, @invitable
          break
        end
      end
    end

    def set_layout
      @model_name
    end
end