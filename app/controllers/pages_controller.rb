class PagesController < ApplicationController

  def help
  end

  def home
    # @featured_projects = Project.indexable.featured.limit 7
    @most_viewed_projects = Project.indexable.most_viewed.limit 7
    # @last_projects = Project.indexable.order('created_at DESC').limit(4)
    @last_projects = Project.indexable.where("projects.id NOT IN(?)", @most_viewed_projects.map(&:id)).order('created_at DESC').limit 5
    @projects = (@most_viewed_projects + @last_projects).uniq.shuffle
    # @top_users = User.top.limit(4)
#    if user_signed_in?
#      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
#      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
#    end

    track_event 'Visited home page'
  end
end
