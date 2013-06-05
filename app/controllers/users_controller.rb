class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :find_user, only: [:show]
  authorize_resource except: [:first_login]

  def show
    title @user.name
    meta_desc "#{@user.name} is on Hackster.io. Come join him and other hardware hackers to showcase your projects."
    @user = @user.decorate
    @broadcasts = @user.broadcasts.where('broadcasts.created_at > ?', 1.day.ago).order('created_at DESC').limit(5).group_by { |b| [b.context_model_type, b.context_model_id, b.event] }.values.map{ |g| g.first }
  end

  def edit
    @user = current_user
    @user.build_avatar unless @user.avatar
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profile updated.' }
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