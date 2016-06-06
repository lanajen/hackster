class ChannelsController < MainBaseController
  before_filter :authenticate_user!

  def show
    @projects = BaseArticle.indexable.last_featured.limit(10)
  end
end