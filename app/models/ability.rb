class Ability
  include CanCan::Ability

  def initialize(resource)

    can :read, [Comment, Issue, User]
    can :read, [Project, Group], private: false

    @user = resource
    member if @user.persisted?
    @user.roles.each{ |role| send role }

    @user.permissions.each do |permission|
      can permission.action.to_sym, permission.permissible_type.constantize, id: permission.permissible_id
    end
  end

  def admin
    # can :manage, :all
  end

  def confirmed_user

  end

  def member
    can :read, [BlogPost, Issue] do |thread|
      @user.can? :read, thread.threadable
    end

    can :manage, [BlogPost, Issue] do |thread|
      @user.can? :update, thread.threadable
    end

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can [:update, :destroy], [Comment], user_id: @user.id

    can :read, [Project, Widget] do |record|
      record.visible_to? @user
    end

    can :create, Project
    can :manage, Project do |project|
      @user.can? :manage, project.team
    end
    can [:update_team, :update_widgets], Project do |project|
      @user.can? :manage, project
    end

    can [:create, :update, :destroy], [Widget] do |record|
      @user.can? :manage, record.project
    end

    can :update, User, id: @user.id
  end
end
