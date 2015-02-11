class PagesController < ApplicationController

  def about
    meta_desc 'What is Hackster.io?'
    title 'What is Hackster.io?'
    # limit = 4
    # @most_popular_projects = Project.indexable.magic_sort.limit 6

    # @most_popular_projects = Project.indexable.most_popular.limit limit
    # @last_projects = Project.indexable.last_public.limit limit
    # @active_projects = Project.last_updated.limit 4
    # @featured_projects = Project.featured.limit 4
    # @wip_projects = Project.wip.limit 4
    # @tools = Platform.where(user_name: %w(spark electricimp arduino raspberry-pi beagleboard teensy)).order(:full_name)
  end

  def achievements
    title 'What are achievements?'
    meta_desc 'What are achievements?'
  end

  def hardwareweekend
    title "Hackster Hardware Weekend Roadshow"
    meta_desc "The Hackster #HardwareWeekend is coming to 10 cities across America! Join us to hack, meet awesome people and win great prizes!"

    render layout: 'blog'
  end

  def help
  end

  def home
    if user_signed_in?
      @last_projects = Project.indexable.last_public.for_thumb_display.limit 12
      @follow_relations_count = current_user.follow_relations.count
      if @follow_relations_count.zero?
        @platforms = Platform.most_members.limit(12)
        @hackers = User.top.limit(24)
      else
        @platforms = current_user.followed_platforms
      end
      render 'home_member'
    else
      @trending_projects = Project.indexable.magic_sort.for_thumb_display.limit 12
      @platforms = Platform.where(user_name: %w(spark delorean metawear tinycircuits intel-edison wunderbar)).for_thumb_display.order(:full_name)
      @lists = List.where(user_name: %w(home-automation blinky-lights lights wearables creature-feature remote-control displays)).limit(6).each_slice(3).to_a

      @typeahead_tags = List.public.order(:full_name).select{|p| p.projects_count >= 5 or p.followers_count >= 10 }.map do |p|
        { tag: p.name, projects: p.projects_count, url: url_for([p, only_path: true]) }
      end
      @suggestions = {
        'Arduino' => '/arduino',
        'Spark Core' => '/spark',
        'Home automation' => '/l/home-automation',
        'Blinky lights' => '/l/blinky-lights',
        'Raspberry Pi' => '/raspberry-pi',
        'Wearables' => '/l/wearables',
        'Intel Edison' => '/intel-edison',
        'Pets' => '/l/creature-feature',
      }
      render 'home_visitor'
    end

    # track_event 'Visited home page'
  end

  def infringement_policy
    meta_desc 'Read our infringement notice policy.'
    title 'Infringement notice policy'
  end

  def jobs
    title 'Jobs at Hackster'
    meta_desc "Join the Hackster team to help more hackers make things."
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
