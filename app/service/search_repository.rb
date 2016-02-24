class SearchRepository
  RESULTS_PER_PAGE = 50

  attr_accessor :params

  def initialize params
    self.params = params
  end

  def search
    query = params[:q] ? CGI::unescape(params[:q].to_s) : nil
    models = params[:type] ? [params[:type]] : nil
#    query += ' ' + params[:product_tag].keys.join(' ') if params[:product_tag]
#    query += ' ' + params[:platform_tag].keys.join(' ') if params[:platform_tag]
    results = self.search_models query, models, params[:offset], params[:page], params[:per_page], params[:include_external], params[:platform_id]
#    Search.create(user_id: user_id, results_count: results.count, query: query) unless params[:page]
    results
  end

  protected
    def search_models query, models=nil, offset=nil, page=1, per_page=RESULTS_PER_PAGE, include_external, platform_id
      per_page ||= RESULTS_PER_PAGE
      page ||= 1
      # include_external = true if include_external.nil?
      # filters = []
      # filters << { terms: { model: models } } if models.present?
      # filters << { term: { platform_ids: platform_id } } if platform_id.present?
      Rails.logger.info "Searching for #{query} and model #{models.to_s} (offset: #{offset}, page: #{page}, per_page: #{per_page})"
      opts = {
        facets: 'model',
        page: page,
        hitsPerPage: per_page
      }
      opts[:facetFilters] = models.map{|m| "model:#{m}" }
      if platform_id.present?
        opts[:facets] += ',platforms.id'
        opts[:facetFilters] += "platforms.id:#{platform_id}"
      end
      opts[:facetFilters] = opts[:facetFilters].join(',')
      index = Algolia::Index.new ALGOLIA_INDEX_NAME
      index.search(query, opts)
      # Tire.search ELASTIC_SEARCH_INDEX_NAME, load: true, page: page, per_page: per_page do
      #   query do
      #     string query, default_operator: 'AND'
      #   end
      #   filter :and, filters if filters.any?
      #   facet 'type' do
      #     terms :model
      #   end
      #   sort do
      #     by :popularity, { order: :desc, ignore_unmapped: true }
      #     by "_score"
      #   end
      #   size per_page
      #   from (offset || (per_page.to_i * (page.to_i-1)))
      # end
    end
end