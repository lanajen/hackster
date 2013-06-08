class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :find_user, only: [:show]
  authorize_resource except: [:first_login, :after_registration, :after_registration_save]

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
    old_user = @user.dup

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profile updated.' }
        format.js do
          @user.avatar = nil unless @user.avatar.try(:file_url)
          @user = @user.decorate
          logger.info old_user.interest_tags_string
          logger.info @user.interest_tags_string
          if old_user.interest_tags_string != @user.interest_tags_string or old_user.skill_tags_string != @user.skill_tags_string
            @refresh = true
          end
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

  def after_registration
    @user = current_user
    @user.build_avatar unless @user.avatar
  end

  def after_registration_save
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to user_return_to, notice: 'All set!'
    else
      render action: 'after_registration'
    end
  end
end