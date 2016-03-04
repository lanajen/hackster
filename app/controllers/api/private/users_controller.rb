class Api::Private::UsersController < Api::Private::BaseController

  def autocomplete
    users = if params[:q].present?
      begin
        opts = {
          q: params[:q],
          model_classes: ['User'],
          page: safe_page_params,
          per_page: User.per_page,
        }
        Search.new(opts).hits['user'][:models]
      rescue => e
        []
      end
    else
      []
    end

    users_json = if users.any?
      users.map do |u|
        name = u.full_name.present? ? "#{u.full_name} (#{u.user_name})" : u.user_name
        { id: u.id, text: name }
      end
    else
      [{ id: '-1', text: "No results for #{params[:q]}.", disabled: true }]
    end

    render json: users_json, root: false
  end

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

  def show
    user = {
      id: current_user ? current_user.id : nil,
      isAdmin: current_user ? current_user.is?(:admin) : false,
      csrfToken: form_authenticity_token
    }
    render json: { user: user }
  end
end