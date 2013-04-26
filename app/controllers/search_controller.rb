class SearchController < ApplicationController
  def search
    @results = params[:query].present? ? SearchRepository.new(params).search.results : []
  end
end