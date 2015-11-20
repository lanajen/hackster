class ShortLinksController < ApplicationController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page

  def show
    link = ShortLink.find_by_slug! params[:slug]

    impressionist_async link, '', {}

    redirect_to link.redirect_to_url
  end
end