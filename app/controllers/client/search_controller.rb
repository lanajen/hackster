class Client::SearchController < Client::BaseController

  def search
    title "#{current_platform.name} projects"

    if params[:q].present?
      begin
        opts = params.dup
        opts[:q] += ' spark'
        opts[:type] = 'project'
        opts[:include_external] = true
        opts[:per_page] = Project.per_page
        @results = SearchRepository.new(opts).search.results

        if @results.empty?
          opts = params.dup
          opts[:type] = 'project'
          opts[:per_page] = Project.per_page
          @results = @alternate_results = SearchRepository.new(opts).search.results
        end

        track_event 'Searched projects', { query: params[:q], result_count: @results.total_count, type: params[:type] }
      rescue
        @results = []
      end
    end
  end
end