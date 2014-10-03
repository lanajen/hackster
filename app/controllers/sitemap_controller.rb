class SitemapController < ApplicationController
  PER_PAGE = 100
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

    if page = safe_page_params
      from = (page.to_i-1) * PER_PAGE
      to = from + 99
      @sitemap_pages = @sitemap_pages[from..to]
    end
  end

  private
    def get_sitemap_pages
      Rails.cache.fetch('sitemap', :expires_in => 1.hour) do
        @sitemap_pages = []

        @sitemap_pages << {
          loc: root_url,
          changefreq: 'daily',
          lastmod: Time.now.strftime("%F"),
        }

        @sitemap_pages << {
          loc: tools_url,
          changefreq: 'daily',
          lastmod: Time.now.strftime("%F"),
        }

        @sitemap_pages << {
          loc: hacker_spaces_url,
          changefreq: 'daily',
          lastmod: Time.now.strftime("%F"),
        }

        Project.indexable.find_each do |project|
          @sitemap_pages << {
            loc: "#{url_for(project)}",
            changefreq: 'weekly',
            lastmod: project.updated_at.strftime("%F"),
          }
        end

        Tech.find_each do |tech|
          @sitemap_pages << {
            loc: "#{tech_short_url(tech)}",
            changefreq: 'weekly',
            lastmod: tech.updated_at.strftime("%F"),
          }
        end

        Monologue::Post.published.find_each do |post|
          @sitemap_pages << {
            loc: "http://#{APP_CONFIG['full_host']}#{post.full_url}",
            changefreq: 'monthly',
            lastmod: post.updated_at.strftime("%F"),
          }
        end

        Project.external.find_each do |project|
          @sitemap_pages << {
            loc: "#{external_project_url(project)}",
            changefreq: 'monthly',
            lastmod: project.updated_at.strftime("%F"),
          }
        end

        User.invitation_accepted_or_not_invited.find_each do |user|
          @sitemap_pages << {
            loc: "#{url_for(user)}",
            changefreq: 'weekly',
            lastmod: user.updated_at.strftime("%F"),
          }
        end

        ProductTag.unique_names.find_each do |tag|
          @sitemap_pages << {
            loc: "#{tags_url(CGI::escape(tag.name))}",
            changefreq: 'weekly',
            lastmod: tag.updated_at.strftime("%F"),
          }
        end

        HackerSpace.public.find_each do |space|
          @sitemap_pages << {
            loc: "#{hacker_space_url(space)}",
            changefreq: 'weekly',
            lastmod: space.updated_at.strftime("%F"),
          }
        end
      end
    end
end