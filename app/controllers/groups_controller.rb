class GroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_group, except: [:edit, :redirect_to_show]
  layout 'group'

  def show
    authorize! :read, @group
    @broadcasts = @group.broadcasts.limit 20
    @projects = @group.projects
    @users = @group.members.invitation_accepted_or_not_invited.map(&:user).select{|u| u.invitation_token.nil? }
    @group = @group.decorate
  end

  def qa
    @group = Group.find params[:group_id]
    @issue = @group.issues.first
    @group = @group.decorate
  end

  def edit
    @group = Community.find(params[:id])
    authorize! :update, @group
    @group.build_avatar unless @group.avatar
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
      @group = load_with_user_name Community
    end
end