class MembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_project_mode
  before_filter :load_group
  respond_to :html
  layout :set_layout

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
        redirect_to "/groups/#{@group.id}"
      end
    else
      render action: 'edit', template: "members/#{@model_name.pluralize}/edit"
    end
  end

  private
    def load_group
      @group = if params[:group_id]
        group = Group.find(params[:group_id])
        @promotion = group if group.type == 'Promotion'
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
      when Team
        'project'
      when Promotion
        'promotion'
      else
        'group'
      end
    end
end