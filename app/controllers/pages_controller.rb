class PagesController < ApplicationController

  def help
  end

  def home
    @invite_request = InviteRequest.new

    if user_signed_in?
      render_options = { template: 'pages/home_signed_in' }
      featured_limit = 4

      @most_popular_projects = Project.most_popular.limit 4
      @active_projects = Project.last_updated.limit 4
      @last_projects = Project.last_public.limit 4

      event = 'Visited home page as member'
    else
      render_options = { template: 'pages/home_visitor', layout: 'home_visitor' }
      featured_limit = 6
      event = 'Visited home page as visitor'
    end

    @featured_projects = Project.featured.limit featured_limit

    # @top_users = User.top.limit(4)
#    if user_signed_in?
#      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
#      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
#    end

    render render_options

    track_event event
  end

  def infringement_policy
    meta_desc 'Read our infringement notice policy.'
    title 'Infringement notice policy'
  end

  def ping
    render text: 'pong!'
  end

  def privacy
    meta_desc 'Read our privacy policy.'
    title 'Privacy policy'
  end

  def terms
    meta_desc 'Read our terms of service.'
    title 'Terms of service'
  end
end
