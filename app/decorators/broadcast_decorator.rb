class BroadcastDecorator < ApplicationDecorator
  def created_at
    "#{h.time_ago_in_words(model.created_at)} ago"
  end

  def message show_name=false
#    puts model.inspect
    user_name = h.link_to model.broadcastable.name, model.broadcastable
    project = model.project
    project_name = h.link_to project.name, project if project
    message = case model.context_model_type
    when 'Comment'
      commentable = model.context_model.commentable
      case commentable
      when Project
        "commented on the project #{project_name}"
      when Issue
        commentable_title = h.link_to commentable.title, h.issue_path(project, commentable)
        "commented on the issue #{commentable_title} on #{project_name}"
      when BuildLog
        commentable_title = h.link_to commentable.title, h.log_path(project, commentable)
        "commented on the build log #{commentable_title} on #{project_name}"
      end
    when 'BuildLog', 'Issue'
      case model.context_model
      when Issue
        threadable_type = 'issue'
        threadable_title = h.link_to model.context_model.title, h.issue_path(project, model.context_model)
      when BuildLog
        threadable_type = 'build log'
        threadable_title = h.link_to model.context_model.title, h.log_path(project, model.context_model)
      end
      case model.event.to_sym
      when :new
        "added a new #{threadable_type} #{threadable_title} to #{project_name}"
      when :update
        "updated the #{threadable_type} #{threadable_title} for #{project_name}"
      end
    when 'Respect'
      "respected #{project_name}"
    when 'FollowRelation'
      follow_name = case model.context_model.followable_type
      when 'Group'
        group = model.context_model.followable
        h.link_to group.name, platform_short_path(group)
      when 'Project'
        project_name
      when 'User'
        user = model.context_model.followable
        h.link_to user.name, user
      end
      "followed #{follow_name}"
    when 'Project'
      case model.event.to_sym
      when :new
        "published the project #{project_name}"
      when :update
        "updated the project #{project_name}"
      end
    when 'Member'
      group = model.context_model.group
      case group
      when Team
        "joined the project #{project_name}"
      when Platform
        platform_link = h.link_to group.name, h.group_path(group)
        "joined the #{platform_link} community"
      end
    when 'User'
      case model.event.to_sym
      when :new
        "joined Hackster.io"
      when :update
        "updated their profile"
      end
    end
    message = "#{user_name} #{message}" if show_name
    if message
      message.html_safe
    else
      LogLine.create(log_type: :debug, source: :broadcast_decorator, message: "Broadcast #{model.inspect} couldn't be displayed.")
      nil
    end
  end
end