class Client::SearchController < Client::BaseController

  def search
    title "#{current_platform.name} projects"

    if params[:q].present?
      redirect_to tag_path(params[:q].gsub(/^#/, '')) and return if params[:q] =~ /^#/

      begin
        types = params[:type].present? ? [params[:type]] : %w(BaseArticle)
        search_opts = {
          q: params[:q],
          model_classes: types,
          page: safe_page_params,
          per_page: BaseArticle.per_page || params[:per_page].presence,
          platform_id: current_platform.id,
        }
        @results = Search.new(search_opts).hits['base_article']

        if @results[:models].empty? and !current_site.hide_alternate_search_results
          search_opts.delete(:platform_id)
          @results = @alternate_results = Search.new(search_opts).hits['base_article']
        end

        track_event 'Searched projects', { query: params[:q], result_count: @results[:total_count], type: params[:type] }
      rescue
        @results = {}
      end
    end
  end
end
