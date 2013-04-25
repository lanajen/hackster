class ProductRepository
#  PRODUCTS_PER_PAGE = Product.per_page
#
#  attr_accessor :params, :user_id
#
#  def initialize params, user_id=nil
#    self.params = params
#    self.user_id = user_id
#  end
#
#  def alternative_search
#    self.search_products Brand.random_featured
#  end
#
#  def search
#    query = params[:q]
#    location = params[:l]
#    results = self.search_products query, params[:page], location
#    Search.create(user_id: user_id, results_count: results.count, query: query) unless params[:page]
#    results
#  end
#
#  protected
#    def model
#      Product
#    end
#
#    def search_products query, page=nil, location=nil
#      Rails.logger.info "Searching for #{query} at location (#{location.to_s})"
#      model.tire.search(load: true, page: page, per_page: PRODUCTS_PER_PAGE) do
#        query { string query, default_operator: "AND" } if query.present?
#        filter :term, :visible => true
#        filter :geo_distance, lat_lon: location, distance: '20mi' if location
#        sort { by :created_at, 'desc' }
#        sort { by :_geo_distance, 'order' => 'asc', 'lat_lon' => location, 'unit' => 'mi' } if location
#      end
#    end
end