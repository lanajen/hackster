class Admin::LiveChaptersController < Admin::BaseController
  def index
    title "Admin / Live event sets - #{safe_page_params}"
    @fields = {
      'created_at' => 'live_chapters.created_at',
      'event_type' => 'live_chapters.event_type',
      'name' => 'live_chapters.name',
      'city' => 'live_chapters.city',
      'country' => 'live_chapters.country',
    }

    params[:sort_by] ||= 'created_at'

    @live_chapters = filter_for LiveChapter, @fields
  end

  def new
    @live_chapter = LiveChapter.new(params[:live_chapter])
  end

  def create
    @live_chapter = LiveChapter.new(params[:live_chapter])

    if @live_chapter.save
      redirect_to admin_live_chapters_path, :notice => 'New Live event set created'
    else
      render :new
    end
  end

  def edit
    @live_chapter = LiveChapter.find(params[:id])
  end

  def update
    @live_chapter = LiveChapter.find(params[:id])

    if @live_chapter.update_attributes(params[:live_chapter])
      redirect_to admin_live_chapters_path, :notice => 'Live event set successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @live_chapter = LiveChapter.find(params[:id])
    @live_chapter.destroy
    redirect_to admin_live_chapters_path, :notice => 'Live event set successfuly deleted'
  end
end