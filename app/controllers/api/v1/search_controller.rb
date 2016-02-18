class Api::V1::SearchController < Api::V1::BaseController
  before_filter :authenticate_platform_or_user

  def index
    set_surrogate_key_header 'api/search'
    set_cache_control_headers

    @facets = terms = {}

    if params[:q].present?
      begin
        opts = {
          q: params[:q],
          per_page: params[:per_page],
          page: safe_page_params,
          model_classes: %w(BaseArticle),
        }
        opts[:platform_id] = current_platform.id if current_platform
        @search = Search.new(opts).hits['base_article']
        @results = @search[:models]

        @offset = @results[:offset] + 1
        @max = @search[:max]

        # @results.facets['type']['terms'].each do |term|
        #   terms[term['term']] = term['count']
        # end

      rescue => e
        logger.error "Error while searching for #{params[:q]}: #{e.message}"
        @results = []
      end
    end
  end
end