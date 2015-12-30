class Ability
  include CanCan::Ability

  def initialize(resource)
    alias_action :read, :edit, :update, :update_workflow, :moderate, to: :admin

    case resource
    when Platform
      @platform = resource

      platform
    when User
      @user = resource

      can :read, [Comment, User, Thought, Challenge]
      cannot :read, [BaseArticle, Group, SkillRequest]
      can :read, [BaseArticle, Group], private: false
      can :read, Assignment do |assignment|
        assignment.promotion.pryvate == false
      end
      can :read, Page do |thread|
        @user.can? :read, thread.threadable
      end
      can :read, Announcement do |thread|
        !thread.draft? and @user.can? :read, thread.threadable
      end
      can :read, BuildLog do |thread|
        thread.type == 'BuildLog' and @user.can? :read, thread.threadable and !thread.threadable.private_logs
      end
      can :read, Issue do |thread|
        @user.can? :read, thread.threadable and !thread.threadable.private_issues
      end
      can :join, Group do |group|
        !@user.persisted? and group.access_level == 'anyone'
      end
      can :create, Group
      can :read, Platform

      member if @user.persisted?
      @user.roles.each{ |role| send role }
      # beta_tester if @user.is? :beta_tester

      @user.permissions.each do |permission|
        can permission.action.to_sym, permission.permissible_type.constantize, id: permission.permissible_id
      end
    end
  end

  def admin
    can :manage, :all
    cannot [:join, :request_access], Group
  end

  def beta_tester
    can :debug, :all
  end

  def confirmed_user
  end

  def member
    can :create, [HackerSpace, Community, Event, Thought, ]

    can :admin, Address do |address|
      address.addressable_type == 'ChallengeEntry' and address.addressable.user_id == @user.id
    end

    can :admin, Conversation do |conversation|
      @user.in? conversation.participants
    end

    can :create, ChallengeEntry do |entry|
      challenge = entry.challenge
      can_enter_challenge?(challenge) and challenge.open_for_submissions?
    end

    can :create, ChallengeIdea do |idea|
      challenge = idea.challenge
      can_enter_challenge?(challenge) and challenge.pre_contest_in_progress?
    end

    can :create, ChallengeRegistration do |registration|
      challenge = registration.challenge
      challenge.open_for_submissions? and @user.can? :read, challenge
    end

    can :manage, ChallengeRegistration, user_id: @user.id

    can :manage, [Announcement, BuildLog, Issue, Page] do |thread|
      @user.can? :manage, thread.threadable
    end

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can :manage, Thought do |thought|
      @user.id == thought.user_id
    end

    can [:update, :destroy], [Comment], user_id: @user.id

    can :read, [BaseArticle, Widget] do |record|
      record.visible_to? @user
    end

    can :claim, BaseArticle do |project|
      project.external? or project.guest_name.present?
    end

    can :update, ProjectCollection do |collection|
      @user.can? :update, collection.collectable
    end

    can :join, Group do |group|
      (member = @user.is_member?(group) and member.invitation_pending?) or case group.access_level
      when 'anyone'
        !@user.is_member?(group)
      # when 'request'
      #   false
      # when 'invite'
      #   member = @user.is_member?(group) and member.invitation_pending?
      end
    end

    can :request_access, Group do |group|
      group.access_level == 'request' and !@user.is_member?(group)
    end
    cannot :request_access, Team
    can :request_access, Team do |team|
      @user.can? :join_team, team.project
    end

    can :join_team, BaseArticle do |project|
      project.event.present? and @user.is_member? project.event
    end

    can :read_members, Community do |community|
      @user.is_member? community
    end

    can :create, [BaseArticle, Community]
    can [:manage, :enter_in_challenge], BaseArticle do |project|
      @user.can?(:manage, project.team) or UserRelationChecker.new(@user).is_platform_moderator?(project)
    end
    cannot :edit_locked, BaseArticle
    can :read, BaseArticle do |project|
      project.pryvate? and @user.is_staff? project
    end
    can [:update_team, :update_widgets, :comment], BaseArticle do |project|
      @user.can? :manage, project
    end

    %w(read edit destroy manage).each do |perm|
      can perm.to_sym, Assignment do |assignment|
        @user.can? perm.to_sym, assignment.promotion
      end
    end
    can :create, Assignment do |assignment|
      @user.can? :manage, assignment.promotion
    end
    can :manage, Grade do |grade|
      @user.can? :manage, grade.assignment
    end

    can [:create, :update, :destroy], [Widget] do |record|
      @user.can? :manage, record.project
    end

    can :update, User, id: @user.id

    can :add_project, Event do |event|
      @user.is_active_member? event
    end

    can [:add_project, :submit_project], Assignment do |assignment|
      @user.is_active_member? assignment.promotion
    end

    can :manage, [ChallengeEntry, ChallengeIdea], user_id: @user.id
    can :admin, [ChallengeEntry, ChallengeIdea] do |entry|
      ChallengeAdmin.where(challenge_id: entry.challenge_id, user_id: @user.id).with_roles(%w(admin judge)).any?
    end

    can :admin, Challenge do |challenge|
      ChallengeAdmin.where(challenge_id: challenge.id, user_id: @user.id).with_roles('admin').any?
    end

    can :create, SkillRequest

    can [:update, :destroy], SkillRequest do |req|
      req.user_id == @user.id
    end

    can :manage, Order, user_id: @user.id

    cannot :update, Part
    can :create, Part
    can :update, Part do |part|
      part.workflow_state.in? Part::EDITABLE_STATES and part.slug.blank?
    end
    can :manage, Part do |part|
      part.platform_id.present? and @user.can? :manage, part.platform
    end

    can :read, ReviewThread do |thread|
      @user.can? :manage, thread.project
    end
  end

  def hackster_moderator
    can :manage, BaseArticle
    can :moderate, Group
  end

  def moderator
    can :review, BaseArticle do |project|
      project.pending_review?
    end
    can :create, ReviewDecision do |decision|
      @user.can? :review, decision.review_thread.project and decision.review_thread.locked == false
    end
    can :update, ReviewDecision do |decision|
      decision.user_id == @user.id and decision.review_thread.locked == false
    end
  end

  def platform
    can :manage, Part, platform_id: @platform.id
  end

  def trusted
  end

  private
    def can_enter_challenge? challenge
      challenge.disable_registration or ChallengeRegistration.has_registered? challenge, @user
    end
end
