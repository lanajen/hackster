class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :find_user, only: [:show]

  def show
    @user = @user.decorate
  end

  def edit
    @user = current_user
    @user.build_avatar unless @user.avatar
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      redirect_to user_profile_url(@user.user_name), notice: 'Profile updated.'
    else
      @user.build_avatar unless @user.avatar
      render action: 'edit'
    end
  end

  def first_login
    @user = current_user
  end
end