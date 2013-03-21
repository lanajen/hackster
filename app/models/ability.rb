class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user

    can :read, [Project, Publication, User]
    member if @user.persisted?

    @user.roles.each{ |role| send role }
  end

  def admin

  end

  def confirmed_user

  end

  def member
    can :create, [Project, Publication]
    can :update, [Project, Publication], user_id: @user.id

    can :update, User, id: @user.id
  end
end
