class SearchController < ApplicationController

  def search
    if params[:q].present?
      @results = SearchRepository.new(params).search.results

      track_event 'Searched projects', { query: params[:q], result_count: @results.size, type: params[:type] }
    end
  end

  def tags
    redirect_to projects_path and return unless params[:tag].present?

    @tag = CGI::unescape params[:tag]
    title "Projects in '#{@tag}'"
    meta_desc "Explore projects tagged '#{@tag}'. Find these and other hardware projects on Hackster.io."
    params[:q] = params[:tag]
    params[:type] = 'project'
    params[:per_page] = Project.per_page
    @results = SearchRepository.new(params).search.results
    params[:per_page] = nil  # so that it doesn't appear in the URL

    track_event 'Searched projects by tag', { tag: @tag, result_count: @results.size, type: params[:type] }
  end
end