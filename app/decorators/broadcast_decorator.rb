class BroadcastDecorator < ApplicationDecorator
  def created_at
    "#{h.time_ago_in_words(model.created_at)} ago"
  end

  def message show_name=false
#    puts model.inspect
    message = case model.broadcastable_type
    when 'Account'
      user_name = h.link_to model.broadcastable.name, model.broadcastable
      case model.context_model_type
      when 'Comment'
        record = model.context_model.commentable
        project = record.respond_to?(:project) ? record.project : record
        project_name = h.link_to project.name, project
#        commentable_type = model.context_model.commentable.class.name.underscore.gsub(/_/, ' ')
        commentable_title = model.context_model.commentable.name
        case model.event.to_sym
        when :new
          "commented on the widget #{commentable_title} on #{project_name}"
        end
      when 'BlogPost', 'Issue'
        project = model.context_model.threadable.respond_to?(:project) ? model.context_model.threadable.project : model.context_model.threadable
        project_name = h.link_to project.name, project
        threadable_type = model.context_model.class.name.underscore.gsub(/_/, ' ')
        threadable_title = h.link_to model.context_model.title, model.context_model
        case model.event.to_sym
        when :new
          "added a new #{threadable_type} #{threadable_title} to #{project_name}"
        when :update
          "updated the #{threadable_type} #{threadable_title} for #{project_name}"
        end
      when 'Project'
        project_name = h.link_to model.context_model.name, model.context_model
        case model.event.to_sym
        when :new
          "created a new project #{project_name}"
        when :update
          "updated the project #{project_name}"
        end
      when 'Publication'
        publication_title = model.context_model.title
        case model.event.to_sym
        when :new
          "added a new publication #{publication_title}"
        when :update
          "updated the publication #{publication_title}"
        end
      when 'User'
        case model.event.to_sym
        when :new
          "joined Hackster.io"
        when :update
          "updated his/her profile"
        end
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