class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user
    
    roles.each{ |role| send role }
  end

  def admin

  end

  def confirmed_user

  end
end
