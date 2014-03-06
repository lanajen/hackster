class Client::SearchController < Client::BaseController

  def search
    title "#{current_platform.name} projects"

    if params[:q].present?
      begin
        params[:q] += ' spark'
        # params[:type] = 'project'
        @results = SearchRepository.new(params).search.results
        params[:q].gsub! ' spark', ''

        track_event 'Searched projects', { query: params[:q], result_count: @results.size, type: params[:type] }
      rescue
        @results = []
      end
    end
  end
end