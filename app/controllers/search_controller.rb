class SearchController < ApplicationController
  before_filter :authenticate_user!

  def search
    @results = SearchRepository.new(params).search.results
  end
end