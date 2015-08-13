class SessionManager
  def expire_all! session_id=nil
    @user.sessions.where.not(session_id: session_id).delete_all
  end

  def initialize user
    @user = user
  end
end