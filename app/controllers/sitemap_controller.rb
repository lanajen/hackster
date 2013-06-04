class SitemapController < ApplicationController
  PER_PAGE = 100
#  skip_before_filter :set_locale
  skip_before_filter :store_location_before
  skip_after_filter :store_location_after
  skip_before_filter :authenticate_user!
  respond_to :xml

  def index
    get_sitemap_pages
    @count = (@sitemap_pages.size.to_f / PER_PAGE).ceil
  end

  def show
    get_sitemap_pages

    if page = params[:page]
      from = (page.to_i-1) * PER_PAGE
      to = from + 99
      @sitemap_pages = @sitemap_pages[from..to]
    end
  end

  private
    def get_sitemap_pages
      @sitemap_pages = []

      @sitemap_pages << {
        loc: root_url,
        changefreq: 'daily',
        lastmod: Time.now.strftime("%F"),
      }

      Project.indexable.find_each do |project|
        @sitemap_pages << {
          loc: "#{project_url(project, host: APP_CONFIG['default_host'])}",
          changefreq: 'monthly',
          lastmod: project.updated_at.strftime("%F"),
        }
      end
    end
end