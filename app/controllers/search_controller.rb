class SearchController < ApplicationController
  def search
    @results = params[:query] ? SearchRepository.new(params).search.results : []
  end
end