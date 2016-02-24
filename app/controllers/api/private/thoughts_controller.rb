class Api::Private::ThoughtsController < Api::Private::BaseController

  def index
    thoughts = Thought
    if params[:hashtag]
      thoughts = thoughts.with_hashtag(params[:hashtag])
    end

    thoughts = thoughts.includes([:comments, :link_datum, :user, user: :avatar]).order(created_at: :desc).paginate(page: safe_page_params)

    render json: thoughts, meta: { next_page: thoughts.next_page }
  end

  def show
    thought = Thought.find params[:id]

    render json: thought, status: :ok
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