class ChannelsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @projects = Project.indexable.last_public.limit(10)
  end
end