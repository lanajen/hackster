class ChannelsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @projects = BaseArticle.indexable.last_public.limit(10)
  end
end