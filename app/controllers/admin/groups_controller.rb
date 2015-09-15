class Admin::GroupsController < Admin::BaseController
  def index
    title "Admin / Groups - #{safe_page_params}"
    @fields = {
      'created_at' => 'groups.created_at',
      'name' => 'groups.full_name',
      'user_name' => 'groups.user_name',
      'type' => 'groups.type',
    }

    params[:sort_by] ||= 'created_at'

    @default_types = %w(Community Promotion Event)
    type ||= params[:type] || @default_types

    collection = Group.where(type: type)
    @groups = filter_for collection, @fields
  end

  def new
    @group = Group.new(params[:group])
  end

  def create
    @group = Group.new(params[:group])

    if @group.save
      redirect_to admin_groups_path, :notice => 'New group created'
    else
      render :new
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

    if @group.update_attributes(params[:group])
      redirect_to admin_groups_path, :notice => 'Group successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to admin_groups_path, :notice => 'Group successfuly deleted'
  end
end