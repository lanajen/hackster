class Api::V1::GroupsController < Api::V1::BaseController
  def index
    groups = Group.where(type: params[:type]).where("groups.full_name ILIKE ?", "%#{params[:q]}%")

    render json: GroupCollectionJsonDecorator.new(groups).node.to_json
  end
end