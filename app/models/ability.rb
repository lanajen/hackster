class Ability
  include CanCan::Ability

  def initialize(resource)
    @user = resource

    can :read, [Comment, User]
    can :read, [Project, Group], private: false
    can :read, Assignment do |assignment|
      assignment.promotion.private == false
    end
    can :read, [BlogPost, Issue, Page] do |thread|
      @user.can? :read, thread.threadable
    end
    can :create, Project, external: true
    can :join, Group do |group|
      !@user.persisted? and group.access_level == 'anyone'
    end

    @user.roles.each{ |role| send role }
    beta_tester if @user.is? :beta_tester
    member if @user.persisted?

    @user.permissions.each do |permission|
      can permission.action.to_sym, permission.permissible_type.constantize, id: permission.permissible_id
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
    can :manage, [BlogPost, Issue, Page] do |thread|
      @user.can? :manage, thread.threadable
    end

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can [:update, :destroy], [Comment], user_id: @user.id

    can :read, [Project, Widget] do |record|
      record.visible_to? @user
    end

    can :claim, Project

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

    can :join_team, Project do |project|
      project.collection_id.present? and project.event.present? and member = @user.linked_to_project_via_group?(project) and !(member.requested_to_join_at.present? and !member.approved_to_join)
    end

    can :read_members, Community do |community|
      @user.is_member? community
    end

    can :create, [Project, Community]
    can :manage, Project do |project|
      @user.can? :manage, project.team
    end
    can :read, Project do |project|
      project.private? and @user.linked_to_project_via_group? project
    end
    can [:update_team, :update_widgets, :comment], Project do |project|
      @user.can? :manage, project
    end
    can :comment_privately, Project do |project|
      project.collection_id.present? and project.assignment.present? and @user.is_staff? project
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

    can :add_project, Assignment do |assignment|
      @user.is_active_member? assignment.promotion
    end

    cannot :debug, :all  # otherwise manage seems to include :debug

    can :debug, Project do |record|
      @user.can? :manage, record or (record.collection_id.present? and record.assignment.present? and @user.is_staff? record)
    end
  end
end
