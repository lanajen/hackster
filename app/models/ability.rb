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
    can [:update, :destroy], Project do |project|
      @user.id.in? project.users.pluck('users.id')
    end

    can [:create, :update, :destroy], Stage do |stage|
#      @user.can? :update, stage.project
      @user.id.in? stage.project.users.pluck('users.id')
    end

    can [:create, :destroy], TeamMember do |team_member|
#      @user.can? :update, team_member.project
      @user.id.in? team_member.project.users.pluck('users.id')
    end

    can :update, User, id: @user.id

    can [:create, :update, :destroy], Widget do |widget|
#      @user.can? :update, widget.stage
      @user.id.in? widget.stage.project.users.pluck('users.id')
    end
  end
end
