class Api::V1::LikesController < Api::V1::BaseController
  before_filter :authenticate_user!
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
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
      raise ActiveRecord::NotFound, 'No `respectable` found'
    end
end