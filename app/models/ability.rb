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

      can :read, Announcement do |thread|
        !thread.draft? and @user.can? :read, thread.threadable
      end

      can :read, Assignment do |assignment|
        assignment.promotion.pryvate == false
      end

      cannot :read, BaseArticle
      can :read, BaseArticle, private: false

      can :read, BuildLog do |thread|
        thread.type == 'BuildLog' and @user.can? :read, thread.threadable and !thread.threadable.private_logs
      end

      can :read, Challenge

      can :read, Comment

      can :create, Group
      can :join, Group do |group|
        !@user.persisted? and group.access_level == 'anyone'
      end
      cannot :read, Group
      can :read, Group, private: false

      can :read, Issue do |thread|
        @user.can? :read, thread.threadable and !thread.threadable.private_issues
      end

      can :read, Page do |thread|
        @user.can? :read, thread.threadable
      end

      can :read, Platform

      can :read, Thought

      can :read, User

      member if @user.persisted?
      @user.roles.each{ |role| send role }

      @user.permissions.each do |permission|
        can permission.action.to_sym, permission.permissible_type.constantize, id: permission.permissible_id
      end
    end
  end

  def admin
    can :manage, :all
    # cannot [:join, :request_access], Group
  end

  def beta_tester
    can :debug, :all
  end

  def confirmed_user
    can :publish, BaseArticle do |project|
      @user.can? :manage, project
    end

    can :create, Comment do |comment|
      commentable = comment.commentable
      @user.can? :read, commentable and (commentable.respond_to?(:locked) ? !commentable.locked : true)
    end

    can :create, Conversation
  end

  def member
    can :admin, Address do |address|
      address.addressable_type == 'ChallengeEntry' and address.addressable.user_id == @user.id
    end

    can_manage_thread Announcement

    can [:add_project, :submit_project], Assignment do |assignment|
      @user.is_active_member? assignment.promotion
    end
    can :create, Assignment do |assignment|
      @user.can? :manage, assignment.promotion
    end
    %w(read manage).each do |perm|
      can perm.to_sym, Assignment do |assignment|
        @user.can? perm.to_sym, assignment.promotion
      end
    end

    can [:description, :enter_in_challenge, :manage], BaseArticle do |project|
      @user.can?(:manage, project.team) or UserRelationChecker.new(@user).is_platform_moderator?(project)
    end
    can :claim, BaseArticle do |project|
      project.external? or project.guest_name.present?
    end
    can [:comment, :update_team, :update_widgets], BaseArticle do |project|
      @user.can? :manage, project
    end
    can :create, BaseArticle
    cannot :edit_locked, BaseArticle
    can :join_team, BaseArticle do |project|
      project.event.present? and @user.is_member? project.event
    end
    cannot :publish, BaseArticle
    can :read, BaseArticle do |record|
      record.visible_to?(@user) or (record.pryvate? and @user.is_staff?(record))
    end

    can_manage_thread BuildLog

    can :admin, Challenge do |challenge|
      ChallengeAdmin.where(challenge_id: challenge.id, user_id: @user.id).with_roles('admin').any?
    end

    can :admin, ChallengeEntry do |entry|
      ChallengeAdmin.where(challenge_id: entry.challenge_id, user_id: @user.id).with_roles(%w(admin judge)).any?
    end
    can :create, ChallengeEntry do |entry|
      challenge = entry.challenge
      can_enter_challenge?(challenge) and challenge.open_for_submissions?
    end
    can :destroy, ChallengeEntry, user_id: @user.id
    can :update, ChallengeEntry do |entry|
      # only allow the entrant to submit entries
      @user.id == entry.user_id and entry.workflow_state_was == 'new' and entry.workflow_state == 'submitted'
    end

    can :admin, ChallengeIdea do |entry|
      ChallengeAdmin.where(challenge_id: entry.challenge_id, user_id: @user.id).with_roles(%w(admin judge)).any?
    end
    can :create, ChallengeIdea do |idea|
      challenge = idea.challenge
      can_enter_challenge?(challenge) and (challenge.activate_pre_contest? and challenge.workflow_state == 'pre_contest_in_progress') or challenge.free_hardware_applications_open?
    end
    can :manage, ChallengeIdea, user_id: @user.id

    can :create, ChallengeRegistration do |registration|
      challenge = registration.challenge
      challenge.open_for_submissions? and @user.can? :read, challenge
    end
    can :manage, ChallengeRegistration, user_id: @user.id

    can :admin, Conversation do |conversation|
      @user.in? conversation.participants
    end

    can [:destroy, :update], Comment, user_id: @user.id

    can :create, Community
    can :read_members, Community do |community|
      @user.is_member? community
    end

    can :add_project, Event do |event|
      @user.is_active_member? event
    end
    can :create, Event

    can :manage, Grade do |grade|
      @user.can? :manage, grade.assignment
    end

    can :join, Group do |group|
      (member = @user.is_member?(group) and member.invitation_pending?) or case group.access_level
      when 'anyone'
        !@user.is_member?(group)
      end
    end
    can :request_access, Group do |group|
      group.access_level == 'request' and !@user.is_member?(group)
    end

    can :create, HackerSpace

    can_manage_thread Issue

    can :destroy, Member, user_id: @user.id

    can :manage, Order, user_id: @user.id

    can_manage_thread Page

    can :create, Part
    cannot :update, Part
    can :update, Part do |part|
      part.workflow_state.in? Part::EDITABLE_STATES and part.slug.blank?
    end
    can :manage, Part do |part|
      part.platform_id.present? and @user.can? :manage, part.platform
    end

    can :update, ProjectCollection do |collection|
      @user.can? :update, collection.collectable
    end

    can :read, ReviewThread do |thread|
      @user.can? :manage, thread.project
    end

    cannot :request_access, Team
    can :request_access, Team do |team|
      @user.can? :join_team, team.project
    end

    can :create, Thought
    can :manage, Thought do |thought|
      @user.id == thought.user_id
    end

    can :update, User, id: @user.id

    can [:create, :destroy, :update], [Widget] do |record|
      @user.can? :manage, record.project
    end
  end

  def hackster_moderator
    can :manage, BaseArticle

    can :moderate, Group
  end

  def moderator
    can :review, BaseArticle do |project|
      project.needs_review?
    end

    can :read, ReviewThread

    can :update, ReviewThread do |thread|
      @user.can? :review, thread.project and thread.locked == false
    end
  end

  def super_moderator
    can :approve, ReviewDecision
  end

  def platform
    can :manage, Part, platform_id: @platform.id
  end

  def spammer
    cannot :publish, BaseArticle

    cannot :create, Comment

    cannot :create, Conversation
  end

  def trusted
  end

  private
    def can_enter_challenge? challenge
      challenge.disable_registration or ChallengeRegistration.has_registered? challenge, @user
    end

    def can_manage_thread model
      can :manage, model do |thread|
        @user.can? :manage, thread.threadable
      end
    end
end
