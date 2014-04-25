module ApplicationHelper
  def active_li_link_to content, link, options={}
    link = url_for link
    klass = 'active' if link == request.path or (options[:truncate] and link.in? request.path)
    content_tag(:li, link_to(content, link), class: klass)
  end

  def affix_top project, user=nil
    affix = 725
    affix += 53 if project.collection_id.present?
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

  def class_for_alert alert, notice
    if alert
      return { class: 'alert-danger' }
    elsif notice
      return { class: 'alert-success' }
    else
      return { style: 'display:none;' }
    end
  end

  def get_reason params
    msg = "Please log in or sign up to continue."
    # group, project, user

    case params[:m]
    when 'group'
      group = Group.find_by_id(params[:id])
    when 'project'
      project = Project.find_by_id(params[:id])
    when 'user'
      user = User.find_by_id(params[:id])
    end

    case params[:reason]
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
      end
    when 'comment'
      if project
        msg = "Please log in or sign up to comment on #{content_tag(:b, project.name)}."
      end
    end
    msg.html_safe
  end

  def partial_name_for_columns project
    project.columns_count == 1 ? 'one_column' : 'two_columns'
  end

  def next_meetup_for_group group_url
    if event = Meetup.new.get_next_meetup(group_url)
      "#{link_to(event['name'], event['event_url'])} on #{event['time'].to_date}".html_safe
    end
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

  def user_is_current?
    user_signed_in? and current_user.id == @user.try(:id)
  end

  def value_for_input param, val
    param.nil? or param == val ? true : false
  end
end
