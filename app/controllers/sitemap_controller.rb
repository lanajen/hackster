class SitemapController < ApplicationController
  DYNAMIC_CATEGORIES = %w(blog platforms lists parts projects product_tags external_projects users hacker_spaces)
  ALL_CATEGORIES = DYNAMIC_CATEGORIES + %w(static)
  PER_PAGE = 100
  skip_before_filter :store_location_before
  skip_after_filter :store_location_after
  skip_before_filter :authenticate_user!
  helper_method :get_pages
  respond_to :xml

  def index
    @pages = { static: 1 }
    DYNAMIC_CATEGORIES.each do |category|
      count = (send("#{category}_query").count.to_f / PER_PAGE).ceil
      @pages[category] = count
    end
  end

  def show
    @category = params[:category]
    @page = (safe_page_params || 1) - 1

    @ok = @category.in?(ALL_CATEGORIES)
  end

  private
    def get_pages category, page
      if category == 'static'
        static_pages
      elsif category.in? DYNAMIC_CATEGORIES
        send("#{category}_pages", page * PER_PAGE)
      end
    end

    def static_pages
      pages = []

      pages << {
        loc: root_url,
        changefreq: 'daily',
        lastmod: Time.now.strftime("%F"),
      }

      pages << {
        loc: platforms_url,
        changefreq: 'daily',
        lastmod: Time.now.strftime("%F"),
      }

      pages << {
        loc: hacker_spaces_url,
        changefreq: 'daily',
        lastmod: Time.now.strftime("%F"),
      }

      pages
    end

    def blog_query
      BlogPost.published
    end

    def blog_pages offset=0
      sitemap_scope(blog_query, offset).map do |post|
        {
          loc: blog_post_url(post.slug),
          changefreq: 'monthly',
          lastmod: post.updated_at.strftime("%F"),
        }
      end
    end

    def projects_query
      Project.indexable
    end

    def projects_pages offset=0
      sitemap_scope(projects_query.includes(:team), offset).map do |project|
        {
          loc: "#{url_for(project)}",
          changefreq: 'weekly',
          lastmod: project.updated_at.strftime("%F"),
        }
      end
    end

    def external_projects_query
      Project.external.where(approved: true)
    end

    def external_projects_pages offset=0
      sitemap_scope(external_projects_query, offset).map do |project|
        {
          loc: "#{external_project_url(project)}",
          changefreq: 'monthly',
          lastmod: project.updated_at.strftime("%F"),
        }
      end
    end

    def lists_query
      List.where(type: 'List').public
    end

    def lists_pages offset=0
      sitemap_scope(lists_query, offset).map do |list|
        {
          loc: url_for(list),
          changefreq: 'daily',
          lastmod: list.updated_at.strftime("%F"),
        }
      end
    end

    def platforms_query
      Platform.public
    end

    def platforms_pages offset=0
      sitemap_scope(platforms_query, offset).map do |platform|
        urls = [
          {
            loc: platform_home_url(platform),
            changefreq: 'daily',
            lastmod: platform.updated_at.strftime("%F"),
          },
          {
            loc: platform_projects_url(platform),
            changefreq: 'daily',
            lastmod: platform.updated_at.strftime("%F"),
          }
        ]
        if platform.enable_products
          urls << {
            loc: platform_products_url(platform),
            changefreq: 'daily',
            lastmod: platform.updated_at.strftime("%F"),
          }
        end
        if platform.enable_parts
          urls << {
            loc: platform_parts_url(platform),
            changefreq: 'daily',
            lastmod: platform.updated_at.strftime("%F"),
          }
        end
        urls
      end.flatten
    end

    def parts_query
      Part.approved
    end

    def parts_pages offset=0
      sitemap_scope(parts_query, offset).map do |part|
        {
          loc: url_for(part),
          changefreq: 'weekly',
          lastmod: part.updated_at.strftime("%F"),
        }
      end
    end

    def users_query
      User.invitation_accepted_or_not_invited.user_name_set
    end

    def users_pages offset=0
      sitemap_scope(users_query, offset).map do |user|
        {
          loc: "#{url_for(user)}",
          changefreq: 'weekly',
          lastmod: user.updated_at.strftime("%F"),
        }
      end
    end

    def product_tags_query
      ProductTag.unique_names
    end

    def product_tags_pages offset=0
      sitemap_scope(product_tags_query, offset).map do |tag|
        {
          loc: "#{tags_url(CGI::escape(tag.name))}",
          changefreq: 'weekly',
          lastmod: tag.updated_at.strftime("%F"),
        }
      end
    end

    def hacker_spaces_query
      HackerSpace.public
    end

    def hacker_spaces_pages offset=0
      sitemap_scope(hacker_spaces_query, offset).map do |space|
        {
          loc: "#{hacker_space_url(space)}",
          changefreq: 'weekly',
          lastmod: space.updated_at.strftime("%F"),
        }
      end
    end

    def sitemap_scope query, offset
      query.send(:order, :id).send(:offset, offset).send(:limit, PER_PAGE)
    end
end