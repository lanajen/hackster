class SearchController < ApplicationController
  def search
    @results = SearchRepository.new(params).search.results
  end
end