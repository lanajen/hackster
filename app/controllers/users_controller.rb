class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :find_user, only: [:show]
  authorize_resource except: [:first_login]

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
      respond_to do |format|
        format.html { redirect_to user_profile_url(@user.user_name), notice: 'Profile updated.' }
        format.js do
          @user.avatar = nil unless @user.avatar.try(:file_url)
          @user = @user.decorate
        end
      end
    else
      @user.build_avatar unless @user.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def first_login
    @user = current_user
  end
end