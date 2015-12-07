class Api::V1::UsersController < Api::V1::BaseController

  def autocomplete
    users = if params[:q].present?
      begin
        params[:type] = 'user'
        params[:per_page] = User.per_page
        SearchRepository.new(params).search.results
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
      id: current_user ? current_user.id : nil,
      isAdmin: current_user ? current_user.is?(:admin) : false,
      csrfToken: form_authenticity_token
    }
    render json: { user: user }
  end
end