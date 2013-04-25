class SearchRepository
  RESULTS_PER_PAGE = 50

  attr_accessor :params

  def initialize params
    self.params = params
  end

  def search
    query = CGI::unescape params[:query].to_s
    model = params[:model]
    results = self.search_models query, params[:page], model
#    Search.create(user_id: user_id, results_count: results.count, query: query) unless params[:page]
    results
  end

  protected
    def search_models query, page=nil, model=nil
      Rails.logger.info "Searching for #{query} and model #{model.to_s}"
      Tire.search BONSAI_INDEX_NAME, load: true, page: page, per_page: RESULTS_PER_PAGE do
        query { string query, default_operator: "AND" } if query.present?
        filter :term, model: model if model.present?
      end
    end
end