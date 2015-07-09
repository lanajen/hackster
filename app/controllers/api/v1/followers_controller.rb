class Api::V1::FollowersController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:create, :destroy]
  before_filter :load_followable, only: [:create, :destroy]
  respond_to :js, :html

  def index
    init_following = { user: [], group: [], project: [], part: [] }
    @following = if user_signed_in?
      current_user.follow_relations.select(:followable_id, :followable_type).inject(init_following) do |h, f|
        case f.followable_type
        when 'User'
          h[:user] << f.followable_id
        when 'Group'
          h[:group] << f.followable_id
        when 'Project'
          h[:project] << f.followable_id
        when 'Part'
          h[:part] << f.followable_id
        end
        h
      end
    else
      init_following
    end
  end

  def create
    FollowRelation.add current_user, @followable

    case @followable
    when Platform, List
      session[:share_modal] = 'followed_share_prompt'
      session[:share_modal_model] = 'followable'
    # when HardwarePart, SoftwarePart, ToolPart, Part
    #   unless current_user.following? @followable.try(:platform)
    #     session[:share_modal] = 'added_to_toolbox_prompt'
    #     session[:share_modal_model] = 'followable'
    #   end
    end
    session[:share_modal_xhr] = true if session[:share_modal]

    render status: :ok, nothing: true

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name, source: params[:source] }
  end

  def destroy
    FollowRelation.destroy current_user, @followable

    render status: :ok, nothing: true

    track_event "Unfollowed #{@followable.class.name}", { id: @followable.id, name: @followable.name }
  end

  private
    def load_followable
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Part Project User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end