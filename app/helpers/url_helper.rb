module UrlHelper

  def assignment_path assignment, opts={}
    course_promotion_assignment_path params_for_assignment(assignment).merge(opts)
  end

  def assignment_url assignment, opts={}
    course_promotion_assignment_url params_for_assignment(assignment).merge(opts)
  end

  def challenge_path challenge, opts={}
    super challenge.slug, opts
  end

  def challenge_url challenge, opts={}
    super challenge.slug, opts
  end

  def new_challenge_idea_path challenge, opts={}
    super challenge.slug, opts
  end

  def new_challenge_idea_url challenge, opts={}
    super challenge.slug, opts
  end

  def challenge_rules_path challenge, opts={}
    super challenge.slug, opts
  end

  def challenge_rules_url challenge, opts={}
    super challenge.slug, opts
  end

  def community_path community, opts={}
    super community.user_name, opts
  end

  def community_url community, opts={}
    super community.user_name, opts
  end

  def course_path course, opts={}
    super params_for_course(course).merge(opts)
  end

  def course_url course, opts={}
    super params_for_course(course).merge(opts)
  end

  def event_path event, opts={}
    hackathon_event_path params_for_event(event).merge(opts)
  end

  def event_url event, opts={}
    hackathon_event_url params_for_event(event).merge(opts)
  end

  def event_info_path event, opts={}
    hackathon_event_info_path event.hackathon.user_name, event.user_name, opts
  end

  def event_projects_path event, opts={}
    hackathon_event_projects_path event.hackathon.user_name, event.user_name, opts
  end

  def edit_group_page_path group, page, opts={}
    case group.type
    when 'Event'
      edit_hackathon_event_page_path(group.hackathon.user_name, group.user_name, page.id)
    when 'Hackathon'
      edit_hackathon_page_path(group.user_name, page.id)
    end
  end

  def group_page_path group, page, opts={}
    case group.type
    when 'Event'
      hackathon_event_page_path(group.hackathon.user_name, group.user_name, page.slug)
    when 'Hackathon'
      hackathon_page_path(group.user_name, page.slug)
    end
  end

  def feedback_comments_path issue, opts={}
    issue_comments_path(issue, opts)
  end

  def group_path group, opts={}
    if group.respond_to? :type
      case group.type
      when 'Community'
        community_path group, opts
      when 'Course'
        super params_for_course(group).merge(opts)
      when 'HackerSpace'
        hacker_space_path(group, opts)
      when 'Hackathon'
        hackathon_path(group, opts)
      when 'Promotion'
        promotion_path group, opts
      when 'University'
        super params_for_group(group).merge(opts)
      when 'Event'
        event_path group, opts
      when 'Platform'
        platform_home_path group, opts
      when 'List'
        list_path group, opts
      else
        super params_for_group(group).merge(opts)
      end
    elsif group.class.name == 'Assignment'
      assignment_path group, opts
    end
  end

  def group_url group, opts={}
    case group.type
    when 'Community'
      community_url group, opts
    when 'Course'
      super params_for_course(group).merge(opts)
    when 'HackerSpace'
      hacker_space_url(group, opts)
    when 'Hackathon'
      hackathon_url(group, opts)
    when 'Promotion'
      promotion_url group, opts
    when 'University'
      super params_for_group(group).merge(opts)
    when 'Event'
      event_url group, opts
    when 'Platform'
      platform_home_url group, opts
    when 'List'
      list_url group, opts
    else
      super params_for_group(group).merge(opts)
    end
  end

  def hackathon_path group, opts={}
    super group.user_name, opts
  end

  def hackathon_url group, opts={}
    super group.user_name, opts
  end

  def hacker_space_path group, opts={}
    super group.user_name, opts
  end

  def hacker_space_url group, opts={}
    super group.user_name, opts
  end

  def issue_path project, issue, opts={}
    project_issue_path(project.user_name_for_url, project.slug_hid, issue.sub_id, opts)
  end

  def issue_url project, issue, opts={}
    project_issue_url(project.user_name_for_url, project.slug_hid, issue.sub_id, opts)
  end

  def issue_form_path_for project, issue, opts={}
    if issue.persisted?
      issue_path(project, issue, opts)
    else
      project_issues_path(project, opts)
    end
  end

  def list_path list, opts={}
    super list.user_name, opts
  end

  def list_url list, opts={}
    super list.user_name, opts
  end

  def login_as_path user
    scheme = APP_CONFIG['use_ssl'] ? 'https' : 'http'
    "#{scheme}://#{APP_CONFIG['full_host']}/?user_token=#{user.authentication_token}&user_email=#{user.email}"
  end

  def log_path project, log, opts={}
    project_log_path(project.user_name_for_url, project.slug_hid, log.sub_id, opts)
  end

  def log_url project, log, opts={}
    project_log_url(project.user_name_for_url, project.slug_hid, log.sub_id, opts)
  end

  def log_form_path_for project, log, opts={}
    if log.persisted?
      project_log_path(project.user_name_for_url, project.slug_hid, log.sub_id, opts)
    else
      project_logs_path(project.user_name_for_url, project.slug_hid, opts)
    end
  end

  def new_assignment_path assignment, opts={}
    new_course_promotion_assignment_path params_for_new_assignment(assignment).merge(opts)
  end

  def part_path part, opts={}
    if part.platform_id
      if defined?(is_whitelabel?) and is_whitelabel?
        client_part_url(part.slug)
      else
        platform_part_path(part.platform.user_name, part.slug)
      end
    else
      ''
    end
  end

  def part_url part, opts={}
    if part.platform_id
      if defined?(is_whitelabel?) and is_whitelabel?
        client_part_url(part.slug)
      else
        platform_part_url(part.platform.user_name, part.slug)
      end
    else
      ''
    end
  end

  def platform_announcements_path platform, opts={}
    if is_whitelabel?
      whitelabel_announcement_index_path(opts)
    else
      super(platform.user_name, opts)
    end
  end

  def platform_announcement_path announcement, opts={}
    if is_whitelabel?
      whitelabel_announcement_path(announcement.sub_id, opts)
    else
      super(announcement.platform.user_name, announcement.sub_id, opts)
    end
  end

  def platform_announcement_url announcement, opts={}
    if is_whitelabel?
      whitelabel_announcement_url(announcement.sub_id, opts)
    else
      super(announcement.platform.user_name, announcement.sub_id, opts)
    end
  end

  def platform_community_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_community_url platform, opts={}
    super platform.user_name, opts
  end

  def platform_products_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_products_url platform, opts={}
    super platform.user_name, opts
  end

  def platform_projects_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_projects_url platform, opts={}
    super platform.user_name, opts
  end

  def platform_parts_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_parts_url platform, opts={}
    super platform.user_name, opts
  end

  def platform_sub_parts_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_sub_platforms_path platform, opts={}
    super platform.user_name, opts
  end

  def product_path product, opts={}
    # super product.slug, opts
    params = params_for_product(product).merge(opts)
    params.delete(:use_route)
    super params
  end

  def product_url product, opts={}
    # super product.slug, opts
    params = params_for_product(product).merge(opts)
    params.delete(:use_route)
    super params
  end

  def project_path project, opts={}
    # if there's a path not found error check that user_name.size >= 3
    params = params_for_project(project).merge(opts)
    params.delete(:use_route)
    super params
  end

  def project_url project, opts={}
    params = params_for_project(project).merge(opts)
    params.delete(:use_route)
    super params
  end

  def project_issues_path project, opts={}
    super params_for_project(project).merge(opts).merge(use_route: nil)
  end

  def project_logs_path project, opts={}
    super params_for_project(project).merge(opts).merge(use_route: nil)
  end

  def project_embed_url project, opts={}
    # force_params = { use_route: 'project_embed' }
    super params_for_project(project).merge(opts)
  end

  def promotion_path promotion, opts={}
    course_promotion_path params_for_promotion(promotion).merge(opts)
  end

  def promotion_url promotion, opts={}
    course_promotion_url params_for_promotion(promotion).merge(opts)
  end

  def platform_home_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_home_url platform, opts={}
    super platform.user_name, opts
  end

  def tag_path tag
    "/projects/tags/#{CGI::escape(tag)}"
  end

  def thought_path thought, opts={}
    "/talk#/posts/#{thought.id}"
  end

  def thought_url thought, opts={}
    APP_CONFIG['full_host'] + thought_path(thought, opts)
  end

  def unsubscribe_url user, opts={}
    update_notifications_url({ user_token: user.authentication_token,
      user_email: user.email }.merge(opts))
  end
  alias_method :change_frequency_url, :unsubscribe_url

  def url_for(options = nil)
    case options
    when Hash
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    when Platform
      options = params_for_group options
      options[:use_route] = 'platform_short'
    when Project, ProjectDecorator
      case options.type
      when 'Product'
        options = params_for_product options
      when 'Project', 'ExternalProject'
        options = params_for_project options
      end
    end
    super options
  end

  def url_for_wiki_page_form group, page
    case group.type
    when 'Event'
      if page.persisted?
        hackathon_event_page_path(group.hackathon.user_name, group.user_name, page.id)
      else
        hackathon_event_pages_path(group.hackathon.user_name, group.user_name)
      end
    when 'Hackathon'
      if page.persisted?
        hackathon_page_path(group.user_name, page.id)
      else
        hackathon_pages_path(group.user_name)
      end
    end
  end

  def url_for_challenge_idea_form challenge, idea
    if idea.persisted?
      challenge_idea_path(challenge.slug, idea.id)
    else
      challenge_ideas_path(challenge.slug)
    end
  end

  def url_for_faq_entry_form challenge, entry
    if entry.persisted?
      challenge_faq_entry_path(challenge, entry.id)
    else
      challenge_faq_entries_path(challenge)
    end
  end

  def users_stats_path user=nil
    if user
      super(user_id: user.id)
    else
      super
    end
  end

  def users_stats_url user=nil
    if user
      super(user_id: user.id)
    else
      super
    end
  end

  def with_subdomain(subdomain='')
    subdomain += "." unless subdomain.blank?
    [subdomain, request.domain].join
  end

  private
    def params_for_assignment assignment
      {
        uni_name: assignment.promotion.course.university.user_name,
        user_name: assignment.promotion.course.user_name,
        promotion_name: assignment.promotion.user_name,
        id: assignment.id_for_promotion,
        # use_route: 'course_promotion_assignment',
      }
    end

    def params_for_new_assignment assignment
      {
        uni_name: assignment.promotion.course.university.user_name,
        user_name: assignment.promotion.course.user_name,
        promotion_name: assignment.promotion.user_name,
      }
    end

    def params_for_course course
      {
        uni_name: course.university.user_name,
        user_name: course.user_name,
      }
    end

    def params_for_event event
      {
        user_name: event.hackathon.user_name,
        event_name: event.user_name,
        # use_route: 'hackathon_event',
      }
    end

    def params_for_promotion promotion
      {
        uni_name: promotion.course.university.user_name,
        user_name: promotion.course.user_name,
        promotion_name: promotion.user_name,
        # use_route: 'course_promotion',
      }
    end

    def params_for_group group, route='group'
      {
        user_name: group.user_name,
        # use_route: route,
      }
    end

    def params_for_product project, force_params={}
      {
        user_name: project.user_name_for_url,
        slug: project.slug,
        use_route: 'product',
      }.merge(force_params)
    end

    def params_for_project project, force_params={}
      {
        project_slug: project.slug_hid,
        user_name: project.user_name_for_url,
        use_route: 'project',
      }
    end
end