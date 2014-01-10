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
#    query += ' ' + params[:tech_tag].keys.join(' ') if params[:tech_tag]
    results = self.search_models query, models, params[:page], params[:per_page]
#    Search.create(user_id: user_id, results_count: results.count, query: query) unless params[:page]
    results
  end

  protected
    def search_models query, models=nil, page=1, per_page=RESULTS_PER_PAGE
      per_page ||= RESULTS_PER_PAGE
      page ||= 1
      filters = []
      filters << { terms: { model: models } } if models.present?
      Rails.logger.info "Searching for #{query} and model #{models.to_s}"
      Tire.search BONSAI_INDEX_NAME, load: true, page: page, per_page: per_page do
        query { string query, default_operator: 'AND' } if query.present?
        filter :and, filters if filters.any?
        filter :term, private: false
        sort { by :created_at, 'desc' }
        size per_page
        from per_page.to_i * (page.to_i-1)
      end
    end
end