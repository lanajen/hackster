class SearchController < ApplicationController
  def search
    if query_string = params[:query]
      tire = Tire.search do
        query { string query_string }
      end
      @results = tire.results
    end
  end
end