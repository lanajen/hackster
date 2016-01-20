class Client::SearchController < Client::BaseController

  def search
    title "#{current_platform.name} projects"

    if params[:q].present?
      redirect_to tag_path(params[:q].gsub(/^#/, '')) and return if params[:q] =~ /^#/

      begin
        opts = params.dup
        opts[:platform_id] = current_platform.id
        opts[:type] = 'base_article'
        opts[:include_external] = true
        opts[:per_page] = BaseArticle.per_page
        @results = SearchRepository.new(opts).search.results

        if @results.empty? and !current_site.hide_alternate_search_results
          opts = params.dup
          opts[:type] = 'base_article'
          opts[:per_page] = BaseArticle.per_page
          @results = @alternate_results = SearchRepository.new(opts).search.results
        end

        track_event 'Searched projects', { query: params[:q], result_count: @results.total_count, type: params[:type] }
      rescue
        @results = []
      end
    end
  end
end