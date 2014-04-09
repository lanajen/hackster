class PagesController < ApplicationController

  def about
    meta_desc 'What is Hackster.io?'
    title 'What is Hackster.io?'

    @most_popular_projects = Project.magic_sort.limit 6
  end

  def help
  end

  def home
    # if user_signed_in?
      render_options = { template: 'pages/home_signed_in' }
      limit = 4

      @most_popular_projects = Project.most_popular.limit limit
      @last_projects = Project.last_public.limit limit
      # @active_projects = Project.last_updated.limit 4
      @featured_projects = Project.featured.limit 4
      @wip_projects = Project.wip.limit 4

      event = 'Visited home page as member'
    # else
    #   render_options = { template: 'pages/home_visitor', layout: 'home_visitor' }
    #   limit = 6
    #   event = 'Visited home page as visitor'
    #   @most_popular_projects = Project.magic_sort.limit limit
    # end


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

  def resources
    meta_desc 'Resources that can help hardware hackers on their journey to making stuff.'
    title 'Resources'
  end

  def terms
    meta_desc 'Read our terms of service.'
    title 'Terms of service'
  end
end
