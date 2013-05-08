class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    can :read, [Comment, Issue, Publication, User]
    can :read, [Project], private: false

    member if @user.persisted?

    @user.roles.each{ |role| send role }
  end

  def admin
#    can :manage, :all
  end

  def confirmed_user

  end

  def member
    can :create, [BlogPost, Issue], bloggable: { user_id: @user.id }
    can [:read, :update, :destroy], [BlogPost, Issue], user_id: @user.id

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can :create, Publication
    can [:update, :destroy], Publication, user_id: @user.id

    can :read, [Project, Stage, Widget] do |record|
      record.visible_to? @user
    end

    can :create, Project
    can [:update, :destroy, :update_team, :update_stages, :update_widgets], Project do |project|
      @user.is_team_member? project
    end

    can [:update, :destroy], [Stage, Widget] do |record|
      @user.is_team_member? record.project
    end

    can :update, User, id: @user.id
  end
end
