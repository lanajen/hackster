class Client::UsersController < Client::BaseController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_user, only: [:show]
  authorize_resource except: [:after_registration, :after_registration_save]

  def show
    impressionist_async @user, "", unique: [:session_hash]  # no need to add :impressionable_type and :impressionable_id, they're already included with @user
    title @user.name
    meta_desc "#{@user.name} is on Hackster.io. Come share your hardware projects with #{@user.name} and other hardware hackers and makers."
    @user = @user.decorate
    @broadcasts = @user.broadcasts.where('broadcasts.created_at > ?', 1.day.ago).order('created_at DESC').limit(5).group_by { |b| [b.context_model_type, b.context_model_id, b.event] }.values.map{ |g| g.first }
    @public_projects = @user.projects.live.order(start_date: :desc, created_at: :desc)
    @public_projects_sorted = @public_projects.group_by{ |p| p.start_date.try(:year) }
    if @public_projects_sorted[nil]
      val = @public_projects_sorted[nil]
      @public_projects_sorted.delete(nil)
      @public_projects_sorted[nil] = val
    end
    # raise @public_projects_sorted.to_s

    track_event 'Viewed profile', @user.to_tracker.merge({ own: (current_user.try(:id) == @user.id) })
  end

  def edit
    @user = current_user
    @user.build_avatar unless @user.avatar
  end

  def update
    @user = current_user

    # copy @user, computes tags_strings first so they're added to the copy
    @user.interest_tags_string
    @user.skill_tags_string
    old_user = @user.dup

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profile updated.' }
        format.js do
          @user.avatar = nil unless @user.avatar.try(:file_url)
          @user = @user.decorate
          if old_user.interest_tags_string != @user.interest_tags_string or old_user.skill_tags_string != @user.skill_tags_string or old_user.user_name != @user.user_name
            @refresh = true
          end
        end

        track_user @user.to_tracker_profile
        track_event 'Updated profile'
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
      if @user.projects.any?
        redirect_to @user.projects.first, notice: "Profile info saved! Now you can start working on your project."
      else
        redirect_to user_return_to, notice: 'Profile info saved!'
      end

      track_user @user.to_tracker_profile
      track_event 'Completed after registration update', {
        completed_avatar: @user.avatar.present?,
        completed_city: @user.city.present?,
        completed_country: @user.country.present?,
        completed_mini_resume: @user.mini_resume.present?,
        completed_name: @user.full_name.present?,
      }
    else
      render action: 'after_registration'
    end
  end
end