class UserOauthFinder
  def initialize(relation = User)
    @relation = relation
  end

  def find_for_oauth provider, auth, resource=nil
    # Rails.logger.info 'auth: ' + auth.to_yaml
      uid = auth.uid
    case provider
    when 'facebook', 'github', 'gplus', 'linkedin'
      email = auth.info.email
      name = auth.info.name
    when 'twitter'
      name = auth.info.name
    when 'windowslive'
      name = auth.info.name
      email = auth.info.emails.try(:first).try(:value)
    when 'arduino'
      email = auth.info.email
    else
      raise 'Provider #{provider} not handled'
    end

    if user = find_for_oauth_by_uid(provider, uid)
      user.match_by = 'uid'
      return user
    end

    if email and user = @relation.where(email: email, invitation_token: nil).first
      user.match_by = 'email'
      return user
    end

    # if name and user = @relation.find_by_full_name(name)
    #   user.match_by = 'name'
    #   return user
    # end
  end

  def find_for_oauth_by_uid(provider, uid)
    @relation.where('authorizations.uid = ? AND authorizations.provider = ?', uid.to_s, provider).joins(:authorizations).readonly(false).first
  end
end