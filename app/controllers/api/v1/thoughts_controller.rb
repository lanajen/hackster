class Api::V1::ThoughtsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    render json: Thought.includes([:comments, :user, user: :avatar]).order(created_at: :desc).limit(50)
  end

  def create
    thought = Thought.new params[:thought]
    authorize! :create, thought

    thought.user = current_user

    if thought.save
      render json: thought, status: :ok
    else
      render json: thought.errors, status: :unprocessable_entity
    end
  end

  def update
    thought = Thought.find params[:id]
    authorize! :update, thought

    if thought.update_attributes params[:thought]
      render json: thought, status: :ok
    else
      render json: thought.errors, status: :bad_request
    end
  end

  def destroy
    thought = Thought.find(params[:id])
    authorize! :destroy, thought
    thought.destroy

    render status: :ok, json: thought
  end
end