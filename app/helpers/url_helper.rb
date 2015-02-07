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

  def external_project_path project, opts={}
    super project.user_name_for_url, "#{project.id}-#{project.slug}", opts
  end

  def external_project_url project, opts={}
    super project.user_name_for_url, "#{project.id}-#{project.slug}", opts
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
      when 'Promotion'
        promotion_path group, opts
      when 'University'
        super params_for_group(group).merge(opts)
      when 'Event'
        event_path group, opts
      when 'Platform'
        platform_short_path group, opts
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
    when 'Promotion'
      promotion_url group, opts
    when 'University'
      super params_for_group(group).merge(opts)
    when 'Event'
      event_url group, opts
    when 'Platform'
      platform_short_url group, opts
    when 'List'
      list_url group, opts
    else
      super params_for_group(group).merge(opts)
    end
  end

  def hacker_space_path group, opts={}
    super group.user_name, opts
  end

  def hacker_space_url group, opts={}
    super group.user_name, opts
  end

  def issue_path project, issue, opts={}
    project_issue_path(project.user_name_for_url, project.slug, issue.sub_id, opts)
  end

  def issue_url project, issue, opts={}
    project_issue_url(project.user_name_for_url, project.slug, issue.sub_id, opts)
  end

  def issue_form_path_for project, issue, opts={}
    if issue.persisted?
      project_issue_path(project.user_name_for_url, project.slug, issue.sub_id, opts)
    else
      project_issues_path(project.user_name_for_url, project.slug, opts)
    end
  end

  def list_path list, opts={}
    super list.user_name, opts
  end

  def list_url list, opts={}
    super list.user_name, opts
  end

  def log_path project, log, opts={}
    project_log_path(project.user_name_for_url, project.slug, log.sub_id, opts)
  end

  def log_url project, log, opts={}
    project_log_url(project.user_name_for_url, project.slug, log.sub_id, opts)
  end

  def log_form_path_for project, log, opts={}
    if log.persisted?
      project_log_path(project.user_name_for_url, project.slug, log.sub_id, opts)
    else
      project_logs_path(project.user_name_for_url, project.slug, opts)
    end
  end

  def new_assignment_path assignment, opts={}
    new_course_promotion_assignment_path params_for_new_assignment(assignment).merge(opts)
  end

  def part_path part, opts={}
    if part.platform_id
      platform_part_path(part.platform.user_name, part.slug)
    else
      ''
    end
  end

  def part_url part, opts={}
    if part.platform_id
      platform_part_url(part.platform.user_name, part.slug)
    else
      ''
    end
  end

  def platform_announcement_path announcement, opts={}
    super(announcement.platform.user_name, announcement.sub_id, opts)
  end

  def platform_announcement_url announcement, opts={}
    super(announcement.platform.user_name, announcement.sub_id, opts)
  end

  def project_path project, opts={}
    # if there's a path not found error check that user_name.size >= 3
    super params_for_project(project).merge(opts)
  end

  def project_url project, opts={}
    super params_for_project(project).merge(opts)
  end

  def project_embed_url project, opts={}
    force_params = { use_route: 'project_embed' }
    super params_for_project(project, force_params).merge(opts)
  end

  def promotion_path promotion, opts={}
    course_promotion_path params_for_promotion(promotion).merge(opts)
  end

  def promotion_url promotion, opts={}
    course_promotion_url params_for_promotion(promotion).merge(opts)
  end

  def tag_path tag
    "/tags/#{CGI::escape(tag)}"
  end

  def platform_short_path platform, opts={}
    super platform.user_name, opts
  end

  def platform_short_url platform, opts={}
    super platform.user_name, opts
  end

  def universal_project_path project, opts={}
    project.external? ? external_project_path(project, opts) : project_path(project, opts)
  end

  def universal_project_url project, opts={}
    project.external? ? external_project_url(project, opts) : project_url(project, opts)
  end

  def url_for(options = nil)
    case options
    when Hash
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    when Platform
      options = params_for_group options
      options[:use_route] = 'platform_short'
    when Project
      options = params_for_project options
    end
    super options
  end

  def url_for_wiki_page_form event, page
    if page.persisted?
      hackathon_event_page_path(event.hackathon.user_name, event.user_name, page.id)
    else
      hackathon_event_pages_path(event.hackathon.user_name, event.user_name)
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
        use_route: 'course_promotion_assignment',
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
        use_route: 'hackathon_event',
      }
    end

    def params_for_promotion promotion
      {
        uni_name: promotion.course.university.user_name,
        user_name: promotion.course.user_name,
        promotion_name: promotion.user_name,
        use_route: 'course_promotion',
      }
    end

    def params_for_group group, route='group'
      {
        user_name: group.user_name,
        use_route: route,
      }
    end

    def params_for_project project, force_params={}
      if project.external
        {
          id: "#{project.id}-#{project.slug}",
          user_name: project.user_name_for_url,
          use_route: 'external_project',
        }.merge(force_params)
      else
        {
          project_slug: project.slug,
          user_name: project.user_name_for_url,
          use_route: 'project',
        }.merge(force_params)
      end
    end
end