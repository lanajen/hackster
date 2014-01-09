class MembersController < ApplicationController
  before_filter :authenticate_user!
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
      record = if @project
        flash[:notice] = 'Team saved.'
        Project.find(params[:project_id])
      else
        flash[:notice] = 'Members saved.'
        @group
      end
      respond_with record
    else
      render action: 'edit', template: "members/#{@model_name.pluralize}/edit"
    end
  end

  private
    def load_group
      @group = if params[:group_id]
        Group.find(params[:group_id])
      else
        @project = Project.find(params[:project_id])
        @project.try(:team)
      end
      # @model_name = @group.class.model_name.to_s.underscore
      @model_name = @group.class.name.underscore
    end

    def set_layout
      @group.is?(:team) ? 'project' : 'group'
    end
end