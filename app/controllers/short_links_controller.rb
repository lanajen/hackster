class ShortLinksController < MainBaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_action :current_site
  skip_before_action :current_platform
  skip_before_filter :set_view_paths
  skip_before_action :set_locale

  def show
    if link = ShortLink.find_by_slug(params[:slug])
      impressionist_async link, '', {}

      redirect_to link.redirect_to_url
    else
      redirect_to (APP_CONFIG['use_ssl'] ? 'https' : 'http') + '://' + APP_CONFIG['full_host'], status: 302
    end
  end
end