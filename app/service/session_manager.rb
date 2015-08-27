class SessionManager
  def activate_session id, opts={save: true}
    return unless id.present?

    active_sessions = @user.active_sessions.dup
    unless active_sessions.include? id
      active_sessions.unshift id
      active_sessions.slice! 5
      @user.active_sessions = active_sessions
      @user.save if opts[:save]
    end
    id
  end

  def deactivate_session id
    return unless id.present?

    active_sessions = @user.active_sessions.dup
    if active_sessions.include? id
      active_sessions.delete id
      @user.active_sessions = active_sessions
      @user.save
    end
  rescue => e
    message = "Failed deactiving session for user '#{id}'."
    AppLogger.new(message, 'error', 'session_manager', e).log_and_notify
  end

  def expire_all! active_session_id=nil
    # @user.sessions.where.not(session_id: active_session_id).delete_all
    @user.active_sessions = active_session_id ? [active_session_id] : []
    @user.save
  end

  def initialize user
    @user = user
  end

  def new_session! opts={}
    # only save the user once
    id = activate_session SecureRandom.hex, save: !opts[:expire]

    expire_all! id if opts[:expire]

    id
  end

  def session_valid? id
    @user.active_sessions.include? id
  end
end