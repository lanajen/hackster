class BaseMailer < ActionMailer::Base
  include MailerHelpers
  include SendGrid

  def prepare_email type, context_type, context_id, opts={}
    raise 'Illegal arguments' unless context_type.kind_of? String and context_id.kind_of? Integer
    puts "Preparing email of type '#{type}' for @context '#{context_type}' of id #{context_id}."
    @context = get_context_for context_type, context_id
    return unless @context

    sendgrid_category type
    if @context.include? :users
      return if @context[:users].empty?
      @context[:users] = @context[:users].uniq
      users_copy = @context[:users]
      users_copy.each_slice(1000) do |users|
        @context[:users] = users
        send_bulk_email type
      end
    elsif @context.include? :user
      send_single_email type, opts
    else
      send_notification_email type
    end
    "deliver!"
  end

  def enqueue_email type, options
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'message_with_context', type, options[:context_type], options[:context_id]
  end

  def enqueue_devise_email type, options, devise_opts
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'devise_message', type, options[:context_type], options[:context_id], devise_opts
  end

  def enqueue_generic_email message
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, message.recipients
  end

  private
    def get_context_for context_type, context_id
      context = {}
      case context_type.to_sym
      when :comment
        comment = context[:comment] = Comment.find(context_id)
        commentable = comment.commentable
        project = context[:project] = case commentable
        when Feedback, Issue
          context[:issue] = comment.commentable
          comment.commentable.threadable
        when Project
          comment.commentable
        end
        author = context[:author] = comment.user
        context[:users] = project.users.with_subscription('new_comment_own') + comment.commentable.commenters.with_subscription('new_comment_commented') - [author]
      when :follower
        follow = context[:follow] = FollowRelation.find(context_id)
        followable = follow.followable
        context[:author] = follow.user
        case followable
        when Project
          context[:project] = followable
          context[:users] = followable.users.with_subscription('new_follow_project')
        when User
          context[:users] = [followable] if 'new_follow_me'.in? followable.subscriptions
        end
      when :invited
        user = context[:user] = User.find(context_id)
        context[:inviter] = user.invited_by if user.invited_by
      when :inviter
        invited = context[:invited] = User.find(context_id)
        context[:user] = invited.invited_by if invited.invited_by
      when :invite_request
        context[:user] = context[:invite] = InviteRequest.find(context_id)
      when :invite_request_notification
        context[:invite] = InviteRequest.find(context_id)
      when :log_line
        context[:error] = LogLine.find(context_id)
      when :membership
        member = context[:member] = Member.find(context_id)
        context[:group] = member.group
        context[:user] = member.user
        context[:inviter] = member.invited_by
      when :participant_invite
        context[:invite] = invite = ParticipantInvite.find(context_id)
        context[:user] = User.new email: invite.email
        context[:project] = invite.project
        context[:issue] = invite.issue
        context[:inviter] = invite.user
      when :project
        project = context[:project] = Project.find(context_id)
        context[:users] = project.users
      when :respect
        respect = context[:respect] = Favorite.find(context_id)
        project = context[:project] = respect.project
        context[:author] = respect.user
        context[:users] = project.users.with_subscription('new_respect_own')
      when :user
         context[:user] = User.find(context_id)
      when :user_informal
         context[:user] = User.find(context_id)
         context[:from_email] = 'Benjamin Larralde<ben@hackster.io>'
      else
        raise "Unknown context: #{context_type}"
      end
      context
    rescue ActiveRecord::RecordNotFound
      false
    end
end
