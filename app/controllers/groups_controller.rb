class GroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_group, only: [:show, :update]
  layout 'group', only: [:edit, :update, :show]
  respond_to :html

  def show
    redirect_to course_path(@group) and return if @group.type == 'Course'

    authorize! :read, @group
    title @group.name
    meta_desc "Join the group #{@group.name} on Hackster.io!"
    @broadcasts = @group.broadcasts.limit 20
    @projects = @group.projects
    @users = @group.members.invitation_accepted_or_not_invited.map(&:user).select{|u| u.invitation_token.nil? }
    @group = @group.decorate

    render "groups/#{@group.identifier.pluralize}/#{self.action_name}"
  end

  def new
    authorize! :create, Community
    title "Create a new community"
    @group = Community.new

    render "groups/#{@group.identifier.pluralize}/#{self.action_name}"
  end

  def create
    @group = Community.new(params[:group])
    authorize! :create, @group

    admin = @group.members.new(user_id: current_user.id)
    @group.private = true

    if @group.save
      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@group.name}!"
      respond_with @group
    else
      render "groups/#{@group.identifier.pluralize}/new"
    end
  end

  def edit
    @group = Community.find(params[:id])
    authorize! :update, @group
    @group.build_avatar unless @group.avatar

    render "groups/#{@group.identifier.pluralize}/#{self.action_name}"
  end

  def update
    authorize! :update, @group
    old_group = @group.dup

    if @group.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @group, notice: 'Profile updated.' }
        format.js do
          @group.avatar = nil unless @group.avatar.try(:file_url)
          @group = @group.decorate
          # if old_group.interest_tags_string != @group.interest_tags_string or old_group.skill_tags_string != @group.skill_tags_string
          #   @refresh = true
          # end

          render "groups/#{@group.identifier.pluralize}/#{self.action_name}"
        end

        track_event 'Updated group'
      end
    else
      @group.build_avatar unless @group.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_group
      @group = load_with_user_name Group
    end
end