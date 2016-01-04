class Admin::LiveEventSetsController < Admin::BaseController
  def index
    title "Admin / Live event sets - #{safe_page_params}"
    @fields = {
      'created_at' => 'live_event_sets.created_at',
      'event_type' => 'live_event_sets.event_type',
      'name' => 'live_event_sets.name',
      'city' => 'live_event_sets.city',
      'country' => 'live_event_sets.country',
    }

    params[:sort_by] ||= 'created_at'

    @live_event_sets = filter_for LiveEventSet, @fields
  end

  def new
    @live_event_set = LiveEventSet.new(params[:live_event_set])
  end

  def create
    @live_event_set = LiveEventSet.new(params[:live_event_set])

    if @live_event_set.save
      redirect_to admin_live_event_sets_path, :notice => 'New Live event set created'
    else
      render :new
    end
  end

  def edit
    @live_event_set = LiveEventSet.find(params[:id])
  end

  def update
    @live_event_set = LiveEventSet.find(params[:id])

    if @live_event_set.update_attributes(params[:live_event_set])
      redirect_to admin_live_event_sets_path, :notice => 'Live event set successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @live_event_set = LiveEventSet.find(params[:id])
    @live_event_set.destroy
    redirect_to admin_live_event_sets_path, :notice => 'Live event set successfuly deleted'
  end
end