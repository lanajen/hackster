class PagesController < ApplicationController
  skip_before_filter :track_visitor, only: [:home, :hardwareweekend]
  skip_after_filter :track_landing_page, only: [:home, :hardwareweekend]
  before_filter :require_no_authentication, only: :arduino_unauthorized
  skip_before_filter :ensure_logged_in, only: [:arduino_unauthorized]

  def about
    meta_desc 'What is Hackster.io?'
    title 'What is Hackster.io?'
  end

  def achievements
    title 'What are achievements?'
    meta_desc 'What are achievements?'
  end

  def arduino_unauthorized
    render layout: false
  end

  def business
    title "Hackster for Business"
    meta_desc "Build a community of hardware developers around your products, we'll show you the way."

    @info_request = InfoRequest.new
  end

  def conduct
    title "Code of Conduct"
  end

  def create_info_request
    @info_request = InfoRequest.new params[:info_request]

    if @info_request.valid?
      @message = Message.new(
        from_email: @info_request.email,
        message_type: 'generic'
      )
      @message.subject = "New info request"
      @message.recipients = 'ben@hackster.io;adam@hackster.io'
      @message.body = "<p>Hi<br><p>Please provide more info about business opportunities:<br>"
      @message.body += "<p>"
      @message.body += "<b>Company: </b>#{@info_request.company}<br>"
      @message.body += "<b>Website: </b>#{@info_request.website}<br>"
      @message.body += "<b>Plan: </b>#{@info_request.plan.compact.to_sentence}<br>"
      @message.body += "<b>Needs: </b>#{@info_request.needs}<br>"
      @message.body += "<b>Name: </b>#{@info_request.name}<br>"
      @message.body += "<b>Phone: </b>#{@info_request.phone}<br>"
      @message.body += "<b>Email: </b>#{@info_request.email}<br>"
      @message.body += "<b>Location: </b>#{@info_request.location}<br>"
      @message.body += "<b>Referral: </b>#{@info_request.referral}<br>"
      @message.body += "<b>Promotional code: </b>#{@info_request.promotional_code}<br>"
      @message.body += "</p>"
      MailerQueue.enqueue_generic_email(@message)
      LogLine.create source: 'info_request', log_type: 'info_request', message: @message.body

      flash[:notice] = "Thanks for your request, we'll be in touch soon!"
      render json: { redirect_to: business_path }
    else
      render json: { info_request: @info_request.errors }, status: :unprocessable_entity
    end
  end

  def csrf
    render json: form_authenticity_token
  end

  def hardwareweekend
    unless user_signed_in?
      set_surrogate_key_header 'hhw'
      set_cache_control_headers
    end
    title "Hackster Hardware Weekend Roadshow"
    meta_desc "The Hackster #HardwareWeekend is coming to 10 cities across America! Join us to hack, meet awesome people and win great prizes!"

    render layout: 'blog'
  end

  def help
  end

  def home
    redirect_to projects_path(format: :atom) and return if request.format == :rss

    featured_lists = %w(home-automation lights wearables animals remote-control displays)

    if user_signed_in?
      if params[:count]
        count = BaseArticle.custom_for(current_user).count
        render json: { count: count } and return
      end

      @challenges = Challenge.publyc.active.ends_last

      @projects = BaseArticle.custom_for(current_user).for_thumb_display.includes(:parts, :project_collections, :users).paginate(page: safe_page_params, per_page: 15)
      if @projects.any?
        @followed = current_user.follow_relations.where(follow_relations: { followable_type: %w(Group) }).includes(followable: [:avatar, :cover_image]) + current_user.follow_relations.where(follow_relations: { followable_type: %w(User) }).includes(followable: :avatar) + current_user.follow_relations.where(follow_relations: { followable_type: %w(Part) }).joins("INNER JOIN parts ON parts.id = follow_relations.followable_id").where.not(parts: { platform_id: nil }).includes(followable: [:image, :platform])
        @current_page = safe_page_params || 1
        @next_page = @current_page + 1
        @next_page = nil if @projects.total_pages < @next_page

        unless request.xhr?
          @last_projects = BaseArticle.indexable.last_public.for_thumb_display.limit(12)
          @hackers = User.invitation_accepted_or_not_invited.user_name_set.where("users.id NOT IN (?)", current_user.followed_users.pluck(:id)).joins(:reputation).where("reputations.points > 5").order('RANDOM()').limit(6)
          @lists = List.where(user_name: featured_lists - current_user.followed_lists.pluck(:user_name))
          @platforms = Platform.publyc.where("groups.id NOT IN (?)", current_user.followed_platforms.pluck(:id)).minimum_followers.order('RANDOM()').limit(6)
        end

      else
        unless request.xhr?
          @hackers = User.invitation_accepted_or_not_invited.user_name_set.where.not(id: current_user.followed_users.pluck(:id)).joins(:reputation).where("reputations.points > 5").order('RANDOM()').limit(24)
          @lists = List.where(user_name: featured_lists - current_user.followed_lists.pluck(:user_name))
          @platforms = Platform.publyc.where.not(id: current_user.followed_platforms.pluck(:id)).minimum_followers_strict.order('RANDOM()').limit(12)
        end
        @last_projects = BaseArticle.indexable.last_public.for_thumb_display.limit(12)
      end

      render 'home_member'
    else
      set_cache_control_headers 3600
      set_surrogate_key_header 'home-visitor'
      @trending_projects = BaseArticle.indexable.magic_sort.for_thumb_display.limit 12
      @last_projects = BaseArticle.indexable.last_public.for_thumb_display.limit 12
      @platforms = Platform.publyc.minimum_followers_strict.order('RANDOM()').for_thumb_display.limit 12
      @lists = List.most_members.limit(6)
      @challenges = Challenge.publyc.active.ends_first.limit(2)

      @typeahead_tags = Collection.publyc.order(:full_name).select{|p| p.projects_count >= 5 or p.followers_count >= 10 }.map do |p|
        { tag: p.name, projects: p.projects_count, url: url_for([p]) }
      end
      @suggestions = {
        'Arduino' => '/arduino',
        'Spark Core' => '/particle',
        'Home automation' => '/l/home-automation',
        'Blinky lights' => '/l/lights',
        'Raspberry Pi' => '/raspberry-pi',
        'Wearables' => '/l/wearables',
        'Intel Edison' => '/intel-edison',
        'Animals' => '/l/animals',
      }
      render 'home_visitor'
    end

    # track_event 'Visited home page'
  end

  def infringement_policy
    meta_desc 'Read our infringement notice policy.'
    title 'Infringement notice policy'
  end

  def guidelines
    title 'Content Guidelines'
  end

  def ping
    render text: 'pong!'
  end

  def pdf_viewer
    @url = params[:url]
    render template: 'layouts/pdf_viewer', layout: false
  end

  def privacy
    meta_desc 'Read our privacy policy.'
    title 'Privacy policy'
  end

  def resources
    meta_desc 'Resources that can help hardware hardware developers on their journey to making stuff.'
    title 'Resources'
  end

  def robots
    render "robots/#{Rails.env}"
  end

  def test
    not_found if Rails.env.production?
  end

  def terms
    meta_desc 'Read our terms of service.'
    title 'Terms of service'
  end
end
