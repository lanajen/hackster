class Api::V1::GroupsController < Api::V1::BaseController
  def index
    groups = Group.where(type: params[:type]).where("groups.full_name ILIKE ?", "%#{params[:q]}%").order(:full_name)

    if params[:parent_id]
      groups = groups.where(parent_id: params[:parent_id])
    end

    render json: GroupCollectionJsonDecorator.new(groups).node.to_json
  end

  def create
    group = Group.new params[:group]

    if group.save
      render json: "#{group.class.name}JsonDecorator".constantize.new(group).node.to_json
    else
      render status: :unprocessable_entity, nothing: true
    end
  end
end