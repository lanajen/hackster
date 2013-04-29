class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    can :read, [Comment, Discussion, Project, Publication, User]
    cannot :read, [BlogPost, Discussion]
    can :read, [BlogPost, Discussion], private: false

    member if @user.persisted?

    @user.roles.each{ |role| send role }
  end

  def admin
    can :manage, :all
  end

  def confirmed_user

  end

  def member
    can :create, [BlogPost, Discussion], bloggable: { user_id: @user.id }
    can [:read, :update, :destroy], [BlogPost, Discussion], user_id: @user.id

    can :create, Comment do |comment|
      @user.can? :read, comment.commentable
    end

    can :create, Publication
    can [:update, :destroy], Publication, user_id: @user.id

    can :create, Project
    can [:update, :destroy, :update_team, :update_stages, :update_widgets], Project do |project|
      @user.id.in? project.users.pluck('users.id')
    end

    can :update, User, id: @user.id
  end
end
