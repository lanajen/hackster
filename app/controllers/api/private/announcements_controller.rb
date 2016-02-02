class Api::Private::AnnouncementsController < Api::Private::BaseController

  def index
    render json: Announcement.order(created_at: :desc).limit(10)
  end

  def show
    announcement = Announcement.find params[:id]
    render json: announcement
  end

  def create
    announcement = Announcement.new params[:announcement]
    authorize! :create, announcement

    if announcement.save
      render json: announcement, status: :ok
    else
      render json: announcement.errors, status: :unprocessable_entity
    end
  end

  def update
    announcement = Announcement.find params[:id]
    authorize! :update, announcement

    if announcement.update_attributes params[:announcement]
      render json: announcement.to_json, status: :ok
    else
      errors = announcement.errors.messages
      widget_errors = {}
      announcement.widgets.each{|w| widget_errors[w.id] = w.to_error if w.errors.any? }
      errors['widgets'] = widget_errors
      render json: errors, status: :bad_request
    end
  end

  def destroy
    announcement = Announcement.find(params[:id])
    authorize! :destroy, announcement
    announcement.destroy

    render json: 'Destroyed'
  end
end