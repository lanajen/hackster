class SearchController < ApplicationController

  def search
    if params[:q].present?
      @results = SearchRepository.new(params).search.results

      track_event 'Searched projects', { query: params[:q], result_count: @results.size, type: params[:type] }
    end
  end
end