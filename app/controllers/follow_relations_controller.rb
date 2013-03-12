class FollowRelationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  def create
    current_user.follow @user
    redirect_to user_profile_path(@user.user_name)
  end

  def destroy
    current_user.unfollow @user
    redirect_to user_profile_path(@user.user_name)
  end
end