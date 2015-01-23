class MembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_project_mode, except: [:create, :process_request]
  before_filter :load_group, except: [:process_request]
  respond_to :html
  layout :set_layout, except: [:create, :process_request]

  def create
    authorize! :request_access, @group
    @group.members.create user_id: current_user.id, requested_to_join_at: Time.now
    redirect_to user_return_to, notice: "Your request to join was sent to the team. We'll notify you when they respond!"
  end

  def process_request
    @member = Member.find params[:member_id]
    group_name = @member.group.class.name.humanize.downcase
    case params[:event]
    when 'approve'
      @member.update_attribute :approved_to_join, true
      flash[:notice] = "#{@member.user.name} is now a member of the #{group_name}."
    when 'reject'
      @member.update_attribute :approved_to_join, false
      flash[:notice] = "#{@member.user.name}'s request to join the #{group_name} was rejected."
    end
    redirect_to user_return_to
  end

  def edit
    authorize! :update, @group
    render template: "members/#{@model_name.pluralize}/edit"
  end

  def update
    authorize! :update, @group

    if @group.update_attributes(params[@group.class.model_name.to_s.underscore.to_sym])
      if @project
        flash[:notice] = 'Team saved.'
        respond_with Project.find(params[:project_id])
      else
        flash[:notice] = 'Members saved.'
        redirect_to group_path(@group)
      end
    else
      render action: 'edit', template: "members/#{@model_name.pluralize}/edit"
    end
  end

  def update_guest_name
    authorize! :update, @project

    if @project.update_attributes(params[:project])
      respond_with @project do |format|
        format.html do
          flash[:notice] = 'Team saved.'
          respond_with Project.find(params[:project_id])
        end
      end

    else
      render action: "edit", template: "members/#{@model_name.pluralize}/edit"
    end
  end

  private
    def load_group
      @group = if params[:group_id]
        group = Group.find(params[:group_id])
        instance_variable_set "@#{group.type.underscore}", group
        group
      elsif params[:promotion_id]
        @promotion = Promotion.find(params[:promotion_id])
      else
        @project = Project.find(params[:project_id])
        @project.try(:team)
      end
      # @model_name = @group.class.model_name.to_s.underscore
      @model_name = @group.class.name.underscore
    end

    def set_layout
      case @group
      when HackerSpace, List, Promotion, Platform
        @group.class.name.underscore
      when Team
        'project'
      else
        'group'
      end
    end
end