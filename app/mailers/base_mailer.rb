class BaseMailer < ActionMailer::Base
  include MailerHelpers
  include SendGrid
  add_template_helper UrlHelper

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
    message.recipients.each_slice(1000) do |recipients|
      MailerQueue.perform_async 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, recipients
    end
  end

  private
    def get_context_for context_type, context_id
      context = {}
      case context_type.to_sym
      when :announcement
        context[:announcement] = announcement = Announcement.find context_id
        context[:platform] = platform = announcement.threadable
        context[:users] = platform.followers.with_subscription('follow_platform_activity')
      when :assignment
        user = context[:user] = User.find(context_id)
        assignment = context[:assignment] = user.assignments.where("assignments.submit_by_date < ?", 24.hours.from_now).first
        context[:project] = user.project_for_assignment(assignment).first
      when :badge
        awarded_badge = context[:awarded_badge] = AwardedBadge.find context_id
        context[:badge] = awarded_badge.badge
        user = awarded_badge.awardee
        user.subscribed_to?('new_badge') ? context[:user] = user : context[:users] = []
      when :challenge
        challenge = context[:challenge] = Challenge.find context_id
        context[:users] = challenge.admins
      when :challenge_entry
        entry = context[:entry] = ChallengeEntry.find context_id
        context[:challenge] = entry.challenge
        context[:project] = entry.project
        context[:user] = entry.user
        context[:prize] = entry.prize
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
      when :daily_notification
        user = User.find context_id
        relations = {}

        # get projects newly attached to followed platform
        platform_projects = user.subscribed_to?('follow_platform_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:platforms).where(groups: { private: false }).where('projects.made_public_at > ?', 24.hours.ago).where(projects: { approved: true }).joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
        platform_projects.each do |project|
          platform = Platform.find(project.followable_id)
          relations[platform] = {} unless platform.in? relations.keys
          relations[platform][project.id] = project
        end

        # get projects newly made public by followed users
        user_projects = user.subscribed_to?('follow_user_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:users).where('projects.made_public_at > ?', 24.hours.ago).where(projects: { approved: true }).joins("INNER JOIN follow_relations ON follow_relations.followable_id = users.id AND follow_relations.followable_type = 'User'").where(follow_relations: { user_id: user.id }) : []
        user_projects.each do |project|
          _user = User.find(project.followable_id)
          relations[_user] = {} unless _user.in? relations.keys
          relations[_user][project.id] = project
        end

        # get projects newly added to lists
        list_projects = user.subscribed_to?('follow_list_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:lists).where('project_collections.created_at > ?', 24.hours.ago).joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
        list_projects.each do |project|
          list = List.find(project.followable_id)
          relations[list] = {} unless list.in? relations.keys
          relations[list][project.id] = project
        end

        # arrange projects so that we know how they're related to followables
        projects = {}
        relations.each do |followable, followed_projects|
          followed_projects.each do |project_id, project|
            projects[project_id] = { followables: [], project: project } unless project_id.in? projects.keys
            projects[project_id][:followables] << followable unless followable.in? projects[project_id][:followables]
          end
        end

        # arrange once more to group project by followables
        relations = {}
        projects.each do |project_id, data|
          relations[data[:followables]] = [] unless data[:followables].in? relations.keys
          relations[data[:followables]] << data[:project]
        end

        context[:followables] = relations.keys.flatten.uniq
        context[:projects] = relations
        if context[:projects].any?
          context[:user] = user
        else
          context[:users] = []  # hack to send no email
        end
      when :follower
        follow = context[:follow] = FollowRelation.find(context_id)
        followable = follow.followable
        context[:author] = follow.user
        case followable
        when Group
          context[:group] = followable
          context[:user] = followable
        when Project
          context[:project] = followable
          context[:users] = followable.users.with_subscription('new_follow_project')
        when User
          if 'new_follow_me'.in?(followable.subscriptions)
            context[:user] = followable
          else
            context[:users] = []  # hack to send no email
          end
        end
      when :grade
        grade = context[:grade] = Grade.find(context_id)
        project = context[:project] = grade.project
        case grade.gradable
        when User
          context[:user] = grade.gradable
        when Team
          context[:users] = grade.gradable.users
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
      when :issue
        issue = context[:issue] = Issue.find(context_id)
        project = context[:project] = issue.threadable
        context[:author] = issue.user
        context[:users] = project.users
      when :log_line
        context[:error] = LogLine.find(context_id)
      when :mass_announcement
        context[:users] = case context_id
        when 0  # have made at least one action
          User.with_at_least_one_action
        else
          []
        end
      when :membership
        member = context[:member] = Member.find(context_id)
        context[:group] = group = member.group
        context[:project] = group.project if group.is? :team
        context[:user] = member.user
        context[:inviter] = member.invited_by
      when :membership_request
        member = context[:member] = Member.find(context_id)
        context[:group] = group = member.group
        context[:project] = group.project if group.is? :team
        context[:users] = case group
        when Team
          group.users.where('members.invitation_sent_at IS NULL OR members.invitation_accepted_at IS NOT NULL')
        when Event
          group.members.with_group_roles('organizer').map(&:user)
        when Promotion
          group.members.with_group_roles(%w(ta professor)).map(&:user)
        else
          []
        end
        context[:requester] = member.user
      when :message
        receipt = Receipt.find context_id
        message = context[:comment] = receipt.message
        context[:conversation] = receipt.conversation
        context[:author] = message.user
        context[:user] = receipt.user
      when :new_membership
        member = context[:member] = Member.find(context_id)
        context[:group] = group = member.group
        context[:user] = group
        context[:author] = member.user
      when :participant_invite
        context[:invite] = invite = ParticipantInvite.find(context_id)
        context[:user] = User.new email: invite.email
        context[:project] = invite.project
        context[:issue] = invite.issue
        context[:inviter] = invite.user
      when :project
        project = context[:project] = Project.find(context_id)
        context[:users] = project.users
      when :project_user_informal
        project = context[:project] = Project.find(context_id)
        user = context[:user] = project.users.first
        context[:from_email] = 'Benjamin Larralde<ben@hackster.io>'
        return unless user.subscribed_to? 'other'
      when :respect
        respect = context[:respect] = Respect.find(context_id)
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
      puts "Couldn't find context for record #{context_id} for #{context_type}; skipped email."
      false
    end
end
