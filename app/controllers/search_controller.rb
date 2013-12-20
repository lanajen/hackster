class SearchController < ApplicationController

  def search
    if params[:q].present?
      @results = SearchRepository.new(params).search.results
      # Search.log params: params, user_id: current_user.try(:id), results: @results.size

      track_event 'Searched projects', { query: params[:q], result_count: @results.size, type: params[:type] }
    end
  end

  def tags
    redirect_to projects_path and return unless params[:tag].present?
    params[:tag] = CGI::unescape params[:tag]
    params[:q] = params[:tag]
    @results = SearchRepository.new(params).search.results

    track_event 'Searched projects by tag', { tag: params[:tag], result_count: @results.size, type: params[:type] }
  end
end