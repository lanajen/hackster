class Ability
  include CanCan::Ability

  def initialize(resource)

    can :read, [Comment, Issue, User]
    can :read, [Project], private: false

    @user = resource
    member if @user.persisted?
    @user.roles.each{ |role| send role }
  end

  def admin
    can :manage, :all
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
    can [:read, :update, :destroy, :update_team, :update_stages, :update_widgets], Project do |project|
      @user.is_team_member? project
    end

    can [:create, :update, :destroy], [Widget] do |record|
      @user.is_team_member? record.project
    end

    can :update, User, id: @user.id
  end
end
