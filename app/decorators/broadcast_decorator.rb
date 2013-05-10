class BroadcastDecorator < ApplicationDecorator
  def created_at
    "#{h.time_ago_in_words(model.created_at)} ago"
  end

  def message
#    puts model.inspect
    case model.broadcastable_type
    when 'User'
      user_name = h.link_to model.broadcastable.name, model.broadcastable
      case model.context_model_type
      when 'Comment'
        record = model.context_model.commentable.threadable
        project = record.respond_to?(:project) ? record.project : record
        project_name = h.link_to project.name, project
        commentable_type = model.context_model.commentable.class.name.underscore.gsub(/_/, ' ')
        commentable_title = h.link_to model.context_model.commentable.title, model.context_model.commentable
        case model.event.to_sym
        when :new
          "#{user_name} commented on the #{commentable_type} #{commentable_title} on #{project_name}"
        end
      when 'BlogPost', 'Issue'
        project = model.context_model.threadable.respond_to?(:project) ? model.context_model.threadable.project : model.context_model.threadable
        project_name = h.link_to project.name, project
        threadable_type = model.context_model.class.name.underscore.gsub(/_/, ' ')
        threadable_title = h.link_to model.context_model.title, model.context_model
        case model.event.to_sym
        when :new
          "#{user_name} added a new #{threadable_type} #{threadable_title} to #{project_name}"
        when :update
          "#{user_name} updated the #{threadable_type} #{threadable_title} for #{project_name}"
        end
      when 'Project'
        project_name = h.link_to model.context_model.name, model.context_model
        case model.event.to_sym
        when :new
          "#{user_name} created a new project #{project_name}"
        when :update
          "#{user_name} updated the project #{project_name}"
        end
      when 'Publication'
        publication_title = model.context_model.title
        case model.event.to_sym
        when :new
          "#{user_name} added a new publication #{publication_title}"
        when :update
          "#{user_name} updated the publication #{publication_title}"
        end
      when 'User'
        case model.event.to_sym
        when :new
          "#{user_name} joined Hackster.io"
        when :update
          "#{user_name} updated their profile"
        end
      end
    end
  end
end