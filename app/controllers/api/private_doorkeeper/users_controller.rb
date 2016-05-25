class Api::PrivateDoorkeeper::UsersController < Api::PrivateDoorkeeper::BaseController
  before_filter :doorkeeper_authorize_without_scope!

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

  def show
    user = {
      id: current_user.try(:id),
      isAdmin: current_user.try(:is?, :admin),
      isConfirmed: current_user.try(:is?, :confirmed_user),
    }
    render json: { user: user }
  end
end