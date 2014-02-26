class Ability
  include CanCan::Ability

  def initialize(resource)

    can :read, [Comment, User]
    can :read, [Project, Group], private: false
    can :read, Assignment do |assignment|
      assignment.promotion.private == false
    end

    @user = resource
    member if @user.persisted?
    @user.roles.each{ |role| send role }
    beta_tester if @user.is? :beta_tester

    @user.permissions.each do |permission|
      can permission.action.to_sym, permission.permissible_type.constantize, id: permission.permissible_id
    end
  end

  def admin
    # can :manage, :all
  end

  def beta_tester
    can :debug, :all
  end

  def confirmed_user

  end

  def member
    can :read, [BlogPost] do |thread|
      @user.can? :read, thread.threadable
    end

    can :manage, BlogPost do |thread|
      @user.can? :manage, thread.threadable
    end

    can :manage, [Issue] do |thread|
      @user.can? :manage, thread.threadable or (thread.threadable.assignment_id.present? and @user.is_staff? thread.threadable)
    end

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can [:update, :destroy], [Comment], user_id: @user.id

    can :read, [Project, Widget] do |record|
      record.visible_to? @user
    end

    can :join, Community

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
      project.assignment_id.present? and @user.is_staff? project
    end

    %w(read edit destroy manage).each do |perm|
      can perm.to_sym, Assignment do |assignment|
        @user.can? perm.to_sym, assignment.promotion
      end
    end
    can :create, Assignment do |assignment|
      @user.can? :manage, assignment.promotion
    end

    can [:create, :update, :destroy], [Widget] do |record|
      @user.can? :manage, record.project
    end

    can :update, User, id: @user.id

    cannot :debug, :all  # otherwise manage seems to include :debug

    can :debug, Project do |record|
      @user.can? :manage, record or (record.assignment_id.present? and @user.is_staff? record)
    end
  end
end
