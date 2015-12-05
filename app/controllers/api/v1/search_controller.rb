class Api::V1::SearchController < Api::V1::BaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_filter :authorize_access!
  before_filter :public_api_methods
  before_filter :authenticate_platform_or_user

  def index
    set_surrogate_key_header 'api/search'
    set_cache_control_headers

    @facets = terms = {}

    if params[:q].present?
      begin
        opts = params.dup
        opts[:platform_id] = current_platform.id if current_platform
        opts[:include_external] = true
        @results = SearchRepository.new(opts).search.results

        @offset = @results.offset + 1
        @max = @results.offset + @results.size

        @results.facets['type']['terms'].each do |term|
          terms[term['term']] = term['count']
        end

      rescue => e
        logger.error "Error while searching for #{params[:q]}: #{e.message}"
        @results = []
      end
    end
  end
end