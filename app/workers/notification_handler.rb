# events = [
#   :new, :approved, :rejected, :completed, :awarded
# ]
# context_types = [
#   :assignment, :challenge, :challenge_entry, :grade, :invitation, :announcement, :badge, :comment, :follower, :issue, :message, :request_to_join, :respect
# ]

class NotificationHandler
  attr_accessor :event, :context_type, :context_id, :model, :user_roles

  def initialize event, context_type, context_id, user_roles=[]
    @event = event
    @context_type = context_type
    @context_id = context_id
    @model = if is_class? context_type.camelize.to_s
      context_type.camelize.to_s.constantize.find_by_id context_id
    end
    @user_roles = user_roles
  end

  def notify_all template=nil
    notify_via_email template
    notify_via_web
  end

  def notify_via_email template=nil, opts={}
    @template = template
    if context = get_context_for('email')
      # using deliver_now below is required as of rails 4.2, with the introduction of deliver_later
      BaseMailer.deliver_email(context, find_template, opts).deliver_now! if context.present?
    end
  end

  def notify_via_web
    if context = get_context_for('web')
      Notification.generate event, context
    end
  end

  private
    def find_template
      return @template if @template

      elements = [event, context_type]
      if @model and @model.class.method_defined? :association_name_for_notifications
        elements += ['for', @model.association_name_for_notifications.underscore]
      end
      @template = elements.join('_')
    end

    def get_context_for notification_type
      context = {}
      # context[context_type.to_sym] = context[:model] = model if model

      case context_type.to_sym
      when :announcement
        context[:model] = context[:announcement] = announcement = Announcement.find context_id
        context[:platform] = platform = announcement.threadable
        context[:users] = platform.followers.with_subscription(notification_type, 'follow_platform_activity')
      when :assignment
        user = context[:user] = User.find(context_id)
        context[:model] = assignment = context[:assignment] = user.assignments.where("assignments.submit_by_date > ? AND assignments.submit_by_date < ?", Time.now, 24.hours.from_now).first
        context[:project] = user.project_for_assignment(assignment).first
      when :badge
        context[:model] = awarded_badge = context[:awarded_badge] = AwardedBadge.find context_id
        context[:badge] = awarded_badge.badge
        user = awarded_badge.awardee
        user.subscribed_to?(notification_type, 'new_badge') ? context[:user] = user : context[:users] = []
      when :base_article
        context[:model] = base_article = context[:base_article] = context[:project] = BaseArticle.find(context_id)
        context[:users] = base_article.users
      when :challenge
        context[:model] = challenge = context[:challenge] = Challenge.find context_id
        if event.to_sym == :ending_soon
          context[:users] = challenge.registrants.with_subscription(notification_type, 'contest_reminder') - challenge.entrants
        else
          context[:users] = challenge.admins
          if event.in? [:launched_contest, :judged]
            context[:users] += challenge.registrants
          end
        end
      when :challenge_entry, :challenge_entry_admin
        context[:model] = entry = context[:entry] = ChallengeEntry.find context_id
        context[:challenge] = challenge = entry.challenge
        context[:project] = entry.project
        if context_type.to_sym == :challenge_entry
          context[:user] = entry.user
          context[:prizes] = entry.prizes
        else
          context[:author] = entry.user
          context[:users] = challenge.admins
        end
      when :challenge_idea
        context[:model] = idea = context[:idea] = ChallengeIdea.find context_id
        context[:challenge] = challenge = idea.challenge
        context[:user] = idea.user
      when :challenge_idea_admin
        context[:model] = idea = context[:idea] = ChallengeIdea.find context_id
        context[:author] = idea.user
        context[:challenge] = challenge = idea.challenge
        context[:users] = challenge.admins
      when :challenge_registration
        context[:model] = registration = context[:registration] = ChallengeRegistration.find context_id
        context[:challenge] = challenge = registration.challenge
        context[:user] = registration.user
      when :comment
        context[:model] = comment = context[:comment] = Comment.find(context_id)
        author = context[:author] = comment.user
        commentable = comment.commentable
        case commentable
        when Feedback, Issue, BaseArticle
          project = context[:project] = case commentable
          when Feedback, Issue
            context[:thread] = comment.commentable
            comment.commentable.threadable
          when BaseArticle
            comment.commentable
          end
          context[:users] = project.users.with_subscription(notification_type, 'new_comment_own')
          if comment.has_parent?
            # finds the user who created the parent comment as well as everyone
            # who replied to it
            context[:users] += User.joins(:comments).where(comments: { id: [comment.parent_id] + comment.parent.children(true).pluck(:id) }).with_subscription(notification_type, 'new_comment_commented')
          else
            # finds all the first level comments for commentable
            context[:users] += User.joins(:comments).where(comments: { id: comment.commentable.comments.where(parent_id: nil) }).with_subscription(notification_type, 'new_comment_commented')
          end
          context[:users] -= [author]
        when Thought
          thought = context[:thought] = commentable
          context[:users] = thought.commenters.with_subscription(notification_type, 'new_comment_update_commented').to_a  # to_a is so that uniq! doesn't fail later on
          if thought.user.subscribed_to?(notification_type, 'new_comment_update')
            context[:users] += [thought.user]
          end
          context[:users].uniq!
          context[:users] -= [author]
        when ReviewThread
          context[:thread] = commentable
          context[:project] = commentable.project
          # if comment was posted by a project author, mail everyone else, otherwise mail project authors
          context[:users] = if comment.user_id.in?(commentable.project.users.pluck('users.id'))
            commentable.participants.with_subscription(notification_type, 'updated_review') - commentable.project.users.with_subscription(notification_type, 'updated_review')
          else
            commentable.project.users.with_subscription(notification_type, 'updated_review').reorder(nil)  # user reorder(nil) so that uniq! doesn't fail (uniq! is used down the line)
          end
        end
      when :comment_mention
        context[:model] = comment = context[:comment] = Comment.find context_id
        context[:commentable] = comment.commentable
        context[:author] = comment.user
        context[:users] = comment.mentioned_users
      when :daily_notification
        context = prepare_project_notification notification_type, 24.hours
      when :weekly_notification
        context = prepare_project_notification notification_type, 7.days
      when :monthly_notification
        context = prepare_project_notification notification_type, 1.month
      when :follow_relation
        context[:model] = follow = context[:follow] = FollowRelation.find(context_id)
        followable = follow.followable
        context[:author] = follow.user
        case followable
        when Group
          # context[:group] = followable
          # context[:users] = followable.users.active
          context[:users] = []  # disabled
        when BaseArticle
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
        context[:model] = grade = context[:grade] = Grade.find(context_id)
        project = context[:project] = grade.project
        case grade.gradable
        when User
          context[:user] = grade.gradable
        when Team
          context[:users] = grade.gradable.users
        end
      when :invited
        context[:model] = user = context[:user] = User.find(context_id)
        if user.invited_by
          inviter = context[:inviter] = user.invited_by
          context[:reply_to] = inviter.email
        end
      when :invitation
        context[:model] = invited = context[:invited] = User.find(context_id)
        context[:reply_to] = invited.email
        context[:user] = invited.invited_by if invited.invited_by
      when :issue
        context[:model] = issue = context[:issue] = Issue.find(context_id)
        project = context[:project] = issue.threadable
        context[:author] = author = issue.user
        context[:users] = project.users - [author]
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
        context[:model] = member = context[:member] = Member.find(context_id)
        context[:group] = group = member.group
        context[:project] = group.project if group.is? :team
        context[:user] = member.user
        inviter = context[:inviter] = member.invited_by
        context[:reply_to] = inviter.email
      when :membership_request
        context[:model] = member = context[:member] = Member.find(context_id)
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
      # when :new_membership
      #   context[:model] = member = context[:member] = Member.find(context_id)
      #   context[:group] = group = member.group
      #   context[:users] = group.members.active
      #   context[:author] = member.user
      when :payment
        payment = context[:payment] = Payment.find context_id
        context[:user] = User.new full_name: payment.recipient_name, email: payment.recipient_email
      when :platform
        platform = context[:platform] = Platform.find context_id
        comments = context[:comments] = Comment.joins(:user).joins("INNER JOIN projects ON projects.id = comments.commentable_id AND comments.commentable_type = 'BaseArticle'").joins("INNER JOIN project_collections ON project_collections.project_id = projects.id AND project_collections.collectable_id = %i AND project_collections.collectable_type = 'Group'" % platform.id).where("comments.created_at > ?", 24.hours.ago).order(:created_at)
        if comments.exists? and platform.email.present?
          context[:user] = platform
        else
          context[:users] = []  # send no email
        end
      when :project
        context[:model] = project = context[:project] = BaseArticle.find(context_id)
        context[:users] = project.users
      when :project_user_informal
        project = context[:project] = BaseArticle.find(context_id)
        user = context[:user] = project.users.first
        context[:from_email] = 'Benjamin Larralde<ben@hackster.io>'
        return unless user.subscribed_to? 'other'
      when :project_collection
        collection = ProjectCollection.find(context_id)
        if collection.certified?
          context[:group] = collection.collectable
          context[:project] = project = collection.project
          context[:users] = project.users
        else
          context[:users] = []
        end
      when :order
        order = context[:order] = Order.find context_id
        context[:user] = order.user
      when :receipt
        context[:model] = receipt = Receipt.find context_id
        message = context[:comment] = receipt.receivable
        context[:conversation] = message.commentable
        context[:author] = message.user
        if receipt.user.subscribed_to?(notification_type, 'new_message')
          context[:user] = receipt.user
        else
          context[:users] = []
        end
      when :respect
        context[:model] = respect = context[:respect] = Respect.find(context_id)
        context[:author] = respect.user
        case respect.respectable
        when Comment
          comment = context[:comment] = respect.respectable
          context[:commentable] = comment.commentable
          if comment.user and comment.user.subscribed_to? notification_type, 'new_like'
            context[:user] = comment.user
          else
            context[:users] = []
          end
        when BaseArticle
          project = context[:project] = respect.respectable
          context[:users] = project.users.with_subscription(notification_type, 'new_respect_own').to_a  # added to_a so that .uniq line 235 doesn't add DISTINCT to the query and make it fail
        when Thought
          thought = context[:thought] = respect.respectable
          if thought.user.subscribed_to? notification_type, 'new_like'
            context[:user] = thought.user
          else
            context[:users] = []
          end
        end
      when :review_decision
        context[:decision] = decision = ReviewDecision.find context_id
        context[:thread] = thread = decision.review_thread
        context[:project] = thread.project
        context[:author] = author = decision.user
        context[:users] = (thread.participants.with_subscription(notification_type, 'updated_review') + thread.project.users.with_subscription(notification_type, 'updated_review')).uniq - [author]
      when :thought_mention
        context[:model] = thought = context[:thought] = Thought.find context_id
        context[:author] = thought.user
        context[:users] = thought.mentioned_users
      when :user
        context[:model] = context[:user] = user = User.find(context_id)
        context[:current_platform] = Platform.find_by_user_name(user.platform)
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

    def prepare_project_notification notification_type, time_frame
      context = {}
      user = User.find context_id
      relations = {}

      # double check that we haven't sent the email yet to prevent doubles
      double_check_time_frame = case time_frame
      when 24.hours
        6.hours.ago
      when 7.days
        6.days.ago
      when 1.month
        25.days.ago
      end
      if user.last_sent_projects_email_at.try(:>, double_check_time_frame)
        message = "Prevented sending duplicate new_projects email to #{user.email}."
        log_line = LogLine.create(message: message, log_type: 'warning', source: 'notification_handler')

        context[:users] = []  # send no email
        return
      end

      # get projects newly attached to followed platform
      platform_projects = user.subscribed_to?(notification_type, 'new_projects') ? BaseArticle.publyc.select('projects.*, follow_relations.followable_id').joins(:platforms).where(groups: { private: false }).where('projects.made_public_at > ? AND projects.made_public_at < ?', time_frame.ago, Time.now).approved.joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
      platform_projects.each do |project|
        platform = Platform.find(project.followable_id)
        relations[platform] = {} unless platform.in? relations.keys
        relations[platform][project.id] = project
      end

      # get projects newly made public by followed users
      user_projects = user.subscribed_to?(notification_type, 'new_projects') ? BaseArticle.publyc.select('projects.*, follow_relations.followable_id').joins(:users).where('projects.made_public_at > ? AND projects.made_public_at < ?', time_frame.ago, Time.now).approved.joins("INNER JOIN follow_relations ON follow_relations.followable_id = users.id AND follow_relations.followable_type = 'User'").where(follow_relations: { user_id: user.id }) : []
      user_projects.each do |project|
        _user = User.find(project.followable_id)
        relations[_user] = {} unless _user.in? relations.keys
        relations[_user][project.id] = project
      end

      # get projects newly added to lists
      list_projects = user.subscribed_to?(notification_type, 'new_projects') ? BaseArticle.publyc.select('projects.*, follow_relations.followable_id').joins(:lists).where('project_collections.created_at > ? AND projects.made_public_at < ?', time_frame.ago, Time.now).joins("INNER JOIN follow_relations ON follow_relations.followable_id = groups.id AND follow_relations.followable_type = 'Group'").where(follow_relations: { user_id: user.id }) : []
      list_projects.each do |project|
        list = List.find(project.followable_id)
        relations[list] = {} unless list.in? relations.keys
        relations[list][project.id] = project
      end

      # get projects newly made public by owned parts
      part_projects = user.subscribed_to?(notification_type, 'new_projects') ? BaseArticle.publyc.select('projects.*, follow_relations.followable_id').joins(:parts).where('projects.made_public_at > ? AND projects.made_public_at < ?', time_frame.ago, Time.now).approved.joins("INNER JOIN follow_relations ON follow_relations.followable_id = parts.id AND follow_relations.followable_type = 'Part'").where.not(parts: { platform_id: nil }).where(follow_relations: { user_id: user.id }) : []
      part_projects.each do |project|
        part = Part.find(project.followable_id)
        relations[part] = {} unless part.in? relations.keys
        relations[part][project.id] = project
      end

      # arrange projects so that we know how they're related to followables
      projects = {}
      relations.each do |followable, followed_projects|
        followed_projects.each do |project_id, project|
          projects[project_id] = { followables: [], project: project } unless project_id.in? projects.keys
          projects[project_id][:followables] << followable unless followable.in? projects[project_id][:followables]
        end
      end

      sorted = projects.to_a.sort{ |a, b| b[1][:project].respects_count <=> a[1][:project].respects_count }

      context[:time_frame] = time_frame
      context[:followables] = sorted.map{|v| v[1][:followables] }.flatten.uniq
      context[:projects] = sorted
      if context[:projects].any?
        context[:user] = user
        user.update_attribute :last_sent_projects_email_at, Time.now
      else
        context[:users] = []  # hack to send no email
      end

      context
    end
end