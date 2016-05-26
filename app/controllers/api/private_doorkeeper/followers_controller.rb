# TODO: move it to V2 after figuring out how not to have the share_modal here
class Api::PrivateDoorkeeper::FollowersController < Api::PrivateDoorkeeper::BaseController
  before_filter -> { doorkeeper_authorize! :profile }, only: [:index]
  before_filter -> { doorkeeper_authorize! :follow }, only: [:create, :destroy]
  before_filter :load_followable, only: [:create, :destroy]

  def index
    init_following = { user: [], group: [], basearticle: [], part: [] }
    following = if user_signed_in?
      current_user.follow_relations.select(:followable_id, :followable_type).inject(init_following) do |h, f|
        case f.followable_type
        when 'User'
          h[:user] << f.followable_id
        when 'Group'
          h[:group] << f.followable_id
        when 'BaseArticle'
          h[:basearticle] << f.followable_id
        when 'Part'
          h[:part] << f.followable_id
        end
        h
      end
    else
      init_following
    end

    render json: {
      following: following,
      currentUserId: current_user.try(:id),
    }
  end

  def create
    FollowRelation.add current_user, @followable

    case @followable
    when Platform, List
      session[:share_modal] = 'followed_share_prompt'
      session[:share_modal_model] = 'followable'
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
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Part BaseArticle User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end