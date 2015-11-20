class Admin::ShortLinksController < Admin::BaseController
  def index
    title "Admin / Short links - #{safe_page_params}"
    @fields = {
      'created_at' => 'short_links.created_at',
      'slug' => 'short_links.slug',
      'redirect_to_url' => 'short_links.redirect_to_url',
    }

    params[:sort_by] ||= 'created_at'

    @short_links = filter_for ShortLink, @fields
  end

  def new
    @short_link = ShortLink.new(params[:short_link])
  end

  def create
    @short_link = ShortLink.new(params[:short_link])

    if @short_link.save
      redirect_to admin_short_links_path, :notice => 'New short_link created'
    else
      render :new
    end
  end

  def edit
    @short_link = ShortLink.find(params[:id])
  end

  def update
    @short_link = ShortLink.find(params[:id])

    if @short_link.update_attributes(params[:short_link])
      redirect_to admin_short_links_path, :notice => 'ShortLink successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @short_link = ShortLink.find(params[:id])
    @short_link.destroy
    redirect_to admin_short_links_path, :notice => 'ShortLink successfuly deleted'
  end
end