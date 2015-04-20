# events = [
#   :new, :approved, :rejected, :completed, :awarded
# ]
# context_types = [
#   :assignment, :challenge, :challenge_entry, :grade, :invitation, :announcement, :badge, :comment, :follower, :issue, :message, :request_to_join, :respect
# ]

class NotificationHandler
  attr_accessor :event, :context_type, :context_id, :model

  def initialize event, context_type, context_id
    @event = event
    @context_type = context_type
    @context_id = context_id
    @model = if is_class? context_type.camelize
      context_type.camelize.constantize.find_by_id context_id
    end
  end

  def notify_all template=nil
    notify_via_email template
    # notify_via_web
  end

  def notify_via_email template=nil, opts={}
    @template = template
    context = get_context_for 'email'
    # using deliver_now below is required as of rails 4.2, with the introduction of deliver_later
    BaseMailer.deliver_email(context, find_template, opts).deliver_now
  end

  def notify_via_web
    Notification.generate event, get_context_for('web')
  end

  private
    def find_template
      return @template if @template

      @template = "#{event}_#{context_type}"
      if @model and @model.class.method_defined? :association_name_for_notifications
        @template += '_for_' + @model.association_name_for_notifications.underscore
      end
      @template
    end

    def get_context_for notification_type
      context = {}
      context[context_type.to_sym] = context[:model] = model if model

      case context_type.to_sym
      when :announcement
        context[:announcement] = announcement = Announcement.find context_id
        context[:platform] = platform = announcement.threadable
        context[:users] = platform.followers.with_subscription(notification_type, 'follow_platform_activity')
      when :assignment
        user = context[:user] = User.find(context_id)
        assignment = context[:assignment] = user.assignments.where("assignments.submit_by_date < ?", 24.hours.from_now).first
        context[:project] = user.project_for_assignment(assignment).first
      when :badge
        awarded_badge = context[:awarded_badge] = AwardedBadge.find context_id
        context[:badge] = awarded_badge.badge
        user = awarded_badge.awardee
        user.subscribed_to?(notification_type, 'new_badge') ? context[:user] = user : context[:users] = []
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
          context[:thread] = comment.commentable
          comment.commentable.threadable
        when Project
          comment.commentable
        end
        author = context[:author] = comment.user
        context[:users] = project.users.with_subscription(notification_type, 'new_comment_own') + comment.commentable.commenters.with_subscription(notification_type, 'new_comment_commented') - [author]
      when :daily_notification
        user = User.find context_id
        relations = {}

        # get projects newly attached to followed platform
        platform_projects = user.subscribed_to?(notification_type, 'follow_platform_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:platforms).where(groups: { private: false }).where('projects.made_public_at > ? AND projects.made_public_at < ?', 24.hours.ago, Time.now).where(projects: { approved: true }).joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
        platform_projects.each do |project|
          platform = Platform.find(project.followable_id)
          relations[platform] = {} unless platform.in? relations.keys
          relations[platform][project.id] = project
        end

        # get projects newly made public by followed users
        user_projects = user.subscribed_to?(notification_type, 'follow_user_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:users).where('projects.made_public_at > ?', 24.hours.ago).where(projects: { approved: true }).joins("INNER JOIN follow_relations ON follow_relations.followable_id = users.id AND follow_relations.followable_type = 'User'").where(follow_relations: { user_id: user.id }) : []
        user_projects.each do |project|
          _user = User.find(project.followable_id)
          relations[_user] = {} unless _user.in? relations.keys
          relations[_user][project.id] = project
        end

        # get projects newly added to lists
        list_projects = user.subscribed_to?(notification_type, 'follow_list_activity') ? Project.select('projects.*, follow_relations.followable_id').joins(:lists).where('project_collections.created_at > ?', 24.hours.ago).joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
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
      when :follow_relation
        follow = context[:follow] = FollowRelation.find(context_id)
        followable = follow.followable
        context[:author] = follow.user
        case followable
        when Group
          context[:group] = followable
          context[:user] = followable
        when Project
          context[:project] = followable
          context[:users] = followable.users.with_subscription(notification_type, 'new_follow_project')
        when User
          if followable.subscribed_to?(notification_type, 'new_follow_me')
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
      when :invitation
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
        when 1
          User.with_at_least_one_action[1000..-1]
        else
          []
        end
      when :membership, :membership_invitation
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
      when :receipt
        receipt = Receipt.find context_id
        message = context[:comment] = receipt.receivable
        context[:conversation] = message.commentable
        context[:author] = message.user
        if receipt.user.subscribed_to?(notification_type, 'new_message')
          context[:user] = receipt.user
        else
          context[:users] = []
        end
      when :respect
        respect = context[:respect] = Respect.find(context_id)
        project = context[:project] = respect.respectable
        context[:author] = respect.user
        context[:users] = project.users.with_subscription(notification_type, 'new_respect_own').to_a  # added to_a so that .uniq line 235 doesn't add DISTINCT to the query and make it fail
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

    def is_class? class_name
      klass = Module.const_get class_name
      klass.is_a? Class
    rescue NameError
      false
    end
end