class SearchRepository
  RESULTS_PER_PAGE = 50

  attr_accessor :params

  def initialize params
    self.params = params
  end

  def search
    query = CGI::unescape params[:query].to_s
    models = params[:model] ? params[:model].keys : nil
    query += ' ' + params[:product_tag].keys.join(' ') if params[:product_tag]
    query += ' ' + params[:tech_tag].keys.join(' ') if params[:tech_tag]
    results = self.search_models query, params[:page], models
#    Search.create(user_id: user_id, results_count: results.count, query: query) unless params[:page]
    results
  end

  protected
    def search_models query, page=nil, models=nil
      filters = []
      filters << { terms: { model: models } } if models.present?
      Rails.logger.info "Searching for #{query} and model #{models.to_s}"
      Tire.search BONSAI_INDEX_NAME, load: true, page: page, per_page: RESULTS_PER_PAGE do
        query { string query, default_operator: "AND" } if query.present?
        filter :or, filters if filters.any?
      end
    end
end