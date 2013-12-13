class PagesController < ApplicationController

  def help
  end

  def home
    @invite_request = InviteRequest.new

    if user_signed_in?
      render_options = { template: 'pages/home_signed_in' }
      limit_most_viewed = 4
      limit_last = 8
      event = 'Visited home page as member'
    else
      render_options = { template: 'pages/home_visitor', layout: 'home_visitor' }
      limit_most_viewed = 2
      limit_last = 4
      event = 'Visited home page as visitor'
    end


    # @featured_projects = Project.indexable.featured.limit 7
    @most_viewed_projects = Project.indexable.most_viewed.limit limit_most_viewed
    # @last_projects = Project.indexable.order('created_at DESC').limit(4)
    @last_projects = Project.indexable.where("projects.id NOT IN(?)", @most_viewed_projects.map(&:id)).order('created_at DESC').limit limit_last
    @projects = (@most_viewed_projects + @last_projects).uniq.shuffle
    # @top_users = User.top.limit(4)
#    if user_signed_in?
#      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
#      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
#    end

    render render_options

    track_event event
  end
end
