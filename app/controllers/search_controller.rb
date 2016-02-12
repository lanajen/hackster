class SearchController < ApplicationController

  def search
    redirect_to tag_path(params[:q].gsub(/^#/, '')) and return if params[:q] and params[:q] =~ /^#/

    respond_to do |format|
      format.html do
        do_search
        render
      end
      format.rss { redirect_to search_path(params.merge(format: :atom)), status: :moved_permanently }
      format.atom do
        do_search 'base_article'
        @projects = @results
        render layout: false, template: 'projects/index'
      end
    end
  end

  def tags
    redirect_to projects_path and return unless params[:tag].present?

    begin
      @tag = CGI::unescape params[:tag]
      @projects = BaseArticle.indexable.joins("INNER JOIN tags ON tags.taggable_id = projects.id AND tags.taggable_type = 'BaseArticle'").where(tags: { type: %w(ProductTag PlatformTag) }).where("LOWER(tags.name) = ?", @tag.downcase).uniq
      @projects = @projects.joins(:project_collections).where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group' }) if is_whitelabel?
      @projects = @projects.magic_sort.for_thumb_display.paginate(page: safe_page_params)
      @total = @projects.total_entries

      title "#{@total} #{@tag} Projects"
      meta_desc "Interested in #{@tag}? Explore #{@total} projects tagged with '#{@tag}'. Find these and other hardware projects on #{site_name}."

      # track_event 'Searched projects by tag', { tag: @tag, result_count: @results.size, type: params[:type] }
    rescue => e
      logger.error "Error while searching for #{params[:q]}: #{e.message}"
      @projects = []
      @total = 0
    end
  end

  private
    def do_search restrict_model=nil
      if params[:q].present?
        types = params[:type].present? ? [params[:type]] : %w(BaseArticle User Platform Part)
        search_opts = {
          q: params[:q],
          model_classes: types,
          page: safe_page_params,
          per_page: params[:per_page].presence
        }

        title "Results for #{params[:q]}"
        meta_desc "Browse results for #{params[:q]}. Find hardware platforms, projects and developers on hackster.io."
        begin
          @results = Search.new(search_opts).hits
          # unless @results.total_count.zero?
          #   title "Results for #{params[:q]} - Showing #{@offset} to #{@max} out of #{@results.total_count}"
          #   meta_desc = "Browse #{@results.total_count} results for #{params[:q]}. Find hardware platforms, projects and developers on #{site_name}."
          #   meta_desc += " Page #{safe_page_params}" if safe_page_params and safe_page_params.to_i > 1
          #   meta_desc meta_desc
          # end

          # track_event 'Searched projects', { query: params[:q], result_count: @results.total_count, type: params[:type] }
        # rescue => e
        #   logger.error "Error while searching for #{params[:q]}: #{e.message}"
        #   @results = []
        end
      end
    end
end