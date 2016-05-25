class Api::Private::UsersController < Api::Private::BaseController
  def index
    coordinates = {
      sw_lat: params[:sw_lat],
      sw_lng: params[:sw_lng],
      ne_lat: params[:ne_lat],
      ne_lng: params[:ne_lng],
    }

    users = User.for_map(coordinates).order(last_seen_at: :desc, created_at: :desc)
    if params[:load_users]
      users = users.includes(:avatar).paginate(page: safe_page_params, per_page: 100)
    end

    render json: GeoUserCollectionJsonDecorator.new(users).node(load_all: params[:load_users])
  end
end