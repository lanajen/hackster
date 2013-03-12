class FollowRelationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  def create
    current_user.follow @user
    redirect_to user_profile_path(@user.user_name), notice: "You're now following #{@user.name}."
  end

  def destroy
    current_user.unfollow @user
    redirect_to user_profile_path(@user.user_name), notice: "You've stopped following #{@user.name}."
  end
end