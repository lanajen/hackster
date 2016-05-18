class Api::V1::UsersController < Api::V1::BaseController
  def show
    @user = User.where(id: params[:id]).user_name_set.invitation_accepted_or_not_invited.first!
  end
end