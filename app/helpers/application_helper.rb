module ApplicationHelper
  def active_li_link_to content, link, options={}, options_for_link={}
    link = url_for link
    klass = 'active' if link == request.path or (options.delete(:truncate) and link.in? request.path)
    content_tag :li, link_to(content, link, options_for_link), options.merge(class: klass)
  end

  def affix_top project, user=nil
    affix = 725
    affix += 53 if ProjectCollection.assignment_or_event_for_project?(project.id)
    affix += 52 if project.private and user and user.can? :edit, @project
    affix += 52 if user and user.is_team_member? project, false
    affix += 53 if flash.any?
    affix
  end

  def indefinite_articlerize word, include_word=true
    article = %w(a e i o u).include?(word[0].downcase) ? 'an' : 'a'
    include_word ? "#{article} #{word}" : article
  end

  def auto_link text
    auto_html text do
      # image
      youtube(:width => 400, :height => 250, :autoplay => false)
      gist
      simple_format
      link(:target => 'blank')
    end
  end

  def build_common_for_follow project, followed
    (project.project_collections.map{|c| [c.collectable_type, c.collectable_id]} + project.users.map{|u| ['User', u.id]}) & followed.map{|c| [c.followable_type, c.followable_id] }
  end

  def class_for_alert alert, notice
    if alert
      return { class: 'alert-danger' }
    elsif notice
      return { class: 'alert-success' }
    else
      return { style: 'display:none;' }
    end
  end

  def file_name_from_url url
    uri = URI.parse(url)
    File.basename(uri.path)
  rescue
    url
  end

  def get_reason params
    if flash_disabled?
      f = bootstrap_flash ''
      return f if f.present?
    end

    msg = "Please log in or create an account to get full access to our maker resources and start creating."
    # group, project, user

    case params[:m]
    when 'challenge'
      challenge = Challenge.find_by_id(params[:id])
    when 'group'
      group = Group.find_by_id(params[:id])
    when 'project'
      project = Project.find_by_id(params[:id])
    when 'user'
      user = User.find_by_id(params[:id])
    end

    case params[:reason]
    when 'enter'
      msg = "Please log in or sign up to enter #{content_tag(:b, challenge.name)}."
    when 'project'
      msg = "Please log in or sign up to create a project."
      if group
        article = indefinite_articlerize group.name, false
        msg = "Please log in or sign up to create #{article} #{content_tag(:b, group.name)} project."
      end
    when 'join'
      if group
        msg = "You're one step closer to becoming part of the #{content_tag(:b, group.name)} community."
      end
    when 'respect'
      if project
        msg = "Please log in or sign up to respect #{content_tag(:b, project.name)}."
      end
    when 'follow'
      if project
        msg = "Please log in or sign up to follow #{content_tag(:b, project.name)}."
      elsif user
        msg = "Please log in or sign up to follow #{content_tag(:b, user.name)}."
      elsif group
        msg = "Please log in or sign up to follow #{content_tag(:b, group.name)}."
      end
    when 'comment'
      if project
        msg = "Please log in or sign up to comment on #{content_tag(:b, project.name)}."
      end
    when 'link'
      msg = "Please log in or sign up to submit a link."
      if group
        msg = "Please log in or sign up to submit a link to #{content_tag(:b, group.name)}."
      end
    when 'claim'
      msg = "Please log in or sign up to claim #{content_tag(:b, project.name)}."
    end
    "<div class='alert alert-warning text-center'>#{msg}</div>".html_safe
  end

  def next_meetup_for_group group_url
    if event = Meetup.new.get_next_meetup(group_url)
      "#{link_to(event['name'], event['event_url'])} on #{event['time'].to_date}".html_safe
    end
  end

  def pluralize_without_count(count, noun, text = nil)
    count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
  end

  def roles_with_mask model_class, attribute
    roles = {}
    model_class.send("#{attribute}").each do |role|
      roles[role] = eval "
        ([role] & #{model_class.name}.#{attribute}).map { |r| 2**#{model_class.name}.#{attribute}.index(r) }.sum
      "
    end
    roles
  end

  def site_domain
    is_whitelabel? ? current_site.full_domain : APP_CONFIG['default_domain']
  end

  def site_host
    is_whitelabel? ? current_site.full_domain : APP_CONFIG['default_host']
  end

  def site_twitter
    is_whitelabel? ? current_platform.twitter_handle : '@hacksterio'
  end

  def time_diff_in_natural_language(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = (to_time - from_time).round

    %w(day hour minute second).each do |interval|
      # For each interval type, if the amount of time remaining is greater than
      # one unit, calculate how many units fit into the remaining time.
      if distance_in_seconds >= 1.send(interval)
        delta = (distance_in_seconds / 1.send(interval)).floor
#        distance_in_seconds -= delta.send(interval)
        return I18n.t("datetime.distance_in_words.x_#{interval}s", count: [0, delta].max)
      end
    end
    I18n.t('datetime.distance_in_words.x_seconds', count: 0)
  end

  def time_for_chat time
    l time.strftime('%m/%d %H:%M').in_time_zone(Time.zone), format: :chat
  end

  def user_is_current?
    user_signed_in? and current_user.id == @user.try(:id)
  end

  def user_is_current_or_admin?
    user_is_current? or current_user.try(:is?, :admin)
  end

  def value_for_input param, val
    param.nil? or param == val ? true : false
  end
end
