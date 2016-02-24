class LiveChaptersController < ApplicationController
  def index

    unless user_signed_in?
      surrogate_keys = ['live_chapters']
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers 86400
    end

    @chapters = LiveChapterDecorator.decorate_collection(LiveChapter.order(:virtual, :country, :city))
  end
end