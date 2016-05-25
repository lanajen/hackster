class Api::V2::LikesController < Api::V2::BaseController
  before_filter -> { doorkeeper_authorize! :respect }
  before_filter :load_respectable

  def create
    like = Respect.create_for current_user, @respectable

    if like.persisted?
      render json: { liked: true }, status: :ok
    else
      render json: { liked: false }, status: :unprocessable_entity
    end
  end

  def destroy
    like = Respect.destroy_for current_user, @respectable

    render json: { liked: false }, status: :ok
  end

  private
    def load_respectable
      @respectable = find_respectable
    end

    def find_respectable
      if type = params[:type] and type.in?(%w(Comment))
        return type.classify.constantize.find(params[:id])
      end

      raise ActiveRecord::NotFound, 'No `respectable` found'
    end
end