class NotificationDecorator < ApplicationDecorator
  def message
    notifiable = model.notifiable
    event = model.event.to_sym

    msg = case notifiable
    when Announcement
      announcement = notifiable
      announcement_link = h.link_to announcement.title, h.platform_announcement_path(announcement)
      group = announcement.threadable
      group_link = h.link_to group.name, group
      case event
      when :new
        "New on #{group_link}: #{announcement_link}."
      end
    when Assignment
      assignment = notifiable
      assignment_link = h.link_to assignment.name, assignment
      case event
      when :due
        "Reminder: the assignment #{assignment_link} is due for submission on #{h.l assignment.submit_by_date}."
      end
    when AwardedBadge
      awarded_badge = notifiable
      badge = awarded_badge.badge
      explanation = badge.explanation(awarded_badge.level)
      badges_count = h.pluralize h.current_user.badges_count, 'badge'
      "You've been awarded a new badge for #{explanation}. That's #{badges_count} total, keep it up!"
    when Challenge
      challenge = notifiable
      challenge_link = h.link_to challenge.name, challenge
      case event
      when :pre_contest_ending_soon
        "The precontest of #{challenge_link} is ending soon, time to submit your idea!"
      when :ending_soon
        "#{challenge_link} is ending soon, time to submit your project!"
      when :launched_pre_contest
        "#{challenge_link} is now accepting ideas!"
      when :launched_contest
        "#{challenge_link} is now open for submissions!"
      when :completed
        "The challenge #{challenge_link} is now closed for submissions. Time to award prizes!"
      when :pre_contest_awarded
        "Winners for the #{challenge.pre_contest_label.downcase} of #{challenge_link} have been announced."
      when :pre_contest_winners
        "Your idea has been selected as a winner for the #{challenge.pre_contest_label.downcase} of #{challenge_link}. Congrats!"
      when :judged
        "The results for #{challenge_link} are out!"
      end
    when ChallengeEntry
      entry = notifiable
      challenge = entry.challenge
      challenge_link = h.link_to challenge.name, challenge
      case event
      when :approved
        "Your entry for #{challenge_link} has been approved."
      when :awarded
        "Congratulations! Your entry for #{challenge_link} has been awarded a prize. Follow instructions sent to your email to claim it."
      end
    when ChallengeIdea
      idea = notifiable
      challenge = idea.challenge
      challenge_link = h.link_to challenge.name, challenge
      case event
      when :approved
        "Your idea '#{idea.name}' for #{challenge_link} has been approved."
      when :winner, :awarded
        "Your idea '#{idea.name}' for #{challenge_link} has won!"
      end
    when Comment
      comment = notifiable
      commentable = comment.commentable
      if user = comment.user
        author_link = h.link_to user.name, user
      else
        author_link = 'Someone'
      end
      case event
      when :new
        case commentable
        when BaseArticle, Project, ExternalProject, Article
          project_link = h.link_to commentable.name, commentable
          "#{author_link} commented on #{project_link}."
        when Thought
          thought_link = h.link_to 'an update you follow', commentable
          "#{author_link} commented on #{thought_link}."
        when Issue, BuildLog
          thread_link = h.link_to commentable.title, commentable
          "#{author_link} commented on #{thread_link}."
        when ReviewThread
          thread_link = h.link_to "#{commentable.project.name}'s moderation conversation", commentable
          "#{author_link} commented on #{thread_link}."
        end
      when :mention
        comment_link = h.link_to 'a comment', commentable
        "#{author_link} mentioned you in #{comment_link}."
      end
    when FollowRelation
      followable = notifiable.followable
      follower_link = h.link_to notifiable.user.name, notifiable.user
      case event
      when :new
        name_link = (followable == h.current_user ? 'you' : h.link_to(followable.name, followable))
        "#{follower_link} followed #{name_link}."
      end
    when CommunityMember, EventMember, HackerSpaceMember, PlatformMember, Member
      member = notifiable
      group = member.group
      group_link = if group.is? :team
        project = group.projects.first
        h.link_to project.name, project
      else
        h.link_to group.name, group
      end
      case event
      when :accepted
        user = member.user
        user_link = h.link_to user.name, user
        "#{user_link} has accepted your invitation to join #{group_link}."
      when :new
        invited_by = member.invited_by
        invited_by_link = h.link_to invited_by.name, invited_by
        "#{invited_by_link} has invited you to join #{group_link}."
      end
    when Grade
      grade = notifiable
      if project = grade.project
        project_link = h.link_to project.name, project
        case event
        when :new
          "You've received a new grade for #{project_link}. #{h.link_to 'Click here', '/grades'} to see it."
        end
      end
    when Issue
      issue = notifiable
      project = issue.threadable
      author_link = h.link_to issue.user.name, issue.user
      project_link = h.link_to project.name, project
      issue_link = h.link_to 'an issue', h.issue_path(project, issue)
      case event
      when :new
        "#{author_link} posted #{issue_link} in #{project_link}."
      end
    when Project, ExternalProject, Article, BaseArticle
      project = notifiable
      project_link = h.link_to project.name, project
      case event
      when :approved
        publish_date = if project.made_public_at < Time.now
          'immediately'
        else
          "on #{h.l project.made_public_at}"
        end
        "#{project_link} has been approved and will show on the home page and related platform pages #{publish_date}."
      end
    when Receipt
      receipt = notifiable
      receivable = receipt.receivable
      case receivable
      when Comment
        author_link = h.link_to receivable.user.name, receivable.user
        conversation = receivable.commentable
        "#{author_link} has sent you #{h.link_to 'a message', conversation}."
      end
    when Respect
      respect = notifiable
      respectable = respect.respectable
      user_link = h.link_to respect.user.name, respect.user
      case respectable
      when Comment
        comment_link = h.link_to 'one of your comments', respectable.commentable
        "#{user_link} liked #{comment_link}." if event == :new
      when Project, ExternalProject, Article, BaseArticle
        project_link = h.link_to respectable.name, respectable
        "#{user_link} respected #{project_link}." if event == :new
      when Thought
        thought_link = h.link_to 'one of your updates', respectable
        "#{user_link} liked #{thought_link}." if event == :new
      end
    when Thought
      thought = notifiable
      author_link = h.link_to thought.user.name, thought.user
      thought_link = h.link_to 'an update', thought
      case event
      when :mention
        "#{author_link} mentioned you in #{thought_link}."
      end
    when User
      user = notifiable
      user_link = h.link_to user.name, user

      case event
      when :accepted
        "#{user_link} has accepted your invitation to join Hackster."
      end
    end

    # unless msg.present?
    #   message = if notifiable
    #     "Unknown notification: #{model.inspect}"
    #   else
    #     "Notifiable doesn't exist anymore: #{model.inspect}"
    #   end
    #   if ENV['ENABLE_ERROR_NOTIF']
    #     log_line = LogLine.create(message: message, log_type: 'error', source: 'notification_decorator')
    #     NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification'
    #   else
    #     raise message
    #   end
    # end

    msg.try(:html_safe)

  rescue => e
    AppLogger.new(message, 'error', 'notification_decorator', e).log_and_notify_with_stdout

    raise e if Rails.env.development?
  end
end