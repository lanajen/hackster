class PagesController < ApplicationController

  def about
    meta_desc 'What is Hackster.io?'
    title 'What is Hackster.io?'

    @most_popular_projects = Project.indexable.magic_sort.limit 6
  end

  def help
  end

  def home
    limit = 4

    @most_popular_projects = Project.indexable.most_popular.limit limit
    @last_projects = Project.indexable.last_public.limit limit
    # @active_projects = Project.last_updated.limit 4
    @featured_projects = Project.featured.limit 4
    # @wip_projects = Project.wip.limit 4
    @tools = Tech.where(user_name: %w(spark electricimp arduino raspberry-pi beagleboard teensy)).order(:full_name)

    track_event 'Visited home page'
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
