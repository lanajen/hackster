class SearchController < ApplicationController

  def search
    if params[:q]
      @results = SearchRepository.new(params).search.results
      Search.log params: params, user_id: current_user.try(:id), results: @results.size
    end
  end
end