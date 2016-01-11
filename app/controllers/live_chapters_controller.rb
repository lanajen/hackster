class LiveChaptersController < ApplicationController
  def index
    @chapters = LiveChapterDecorator.decorate_collection(LiveChapter.order(:virtual, :country, :city))
  end
end