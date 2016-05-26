class Api::PrivateDoorkeeper::GroupsController < Api::PrivateDoorkeeper::BaseController
  before_action :doorkeeper_authorize_user_without_scope!

  def index
    groups = Group.where(type: params[:type]).where("groups.full_name ILIKE ?", "%#{params[:q]}%").order(:full_name)

    if params[:parent_id]
      groups = groups.where(parent_id: params[:parent_id])
    end

    render json: GroupCollectionJsonDecorator.new(groups).node.to_json
  end

  def create
    group = Group.new params[:group]

    group.members.new user_id: current_user.id, group_roles: [params[:member_role]]
    if group.save
      render json: "#{group.class.name}JsonDecorator".constantize.new(group).node.to_json
    else
      render status: :unprocessable_entity, nothing: true
    end
  end
end