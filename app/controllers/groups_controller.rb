class GroupsController < ApplicationController
  load_resource

  def show
    @broadcasts = @group.broadcasts.limit 20
    @group = @group.decorate
  end

  def qa
    @group = Group.find params[:group_id]
    @issue = @group.issues.first
    @group = @group.decorate
  end
end