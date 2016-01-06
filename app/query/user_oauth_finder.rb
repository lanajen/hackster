class UserOauthFinder
  def initialize(relation = User)
    @relation = relation
  end

  def find_for_oauth provider, data
    uid = data.uid

    if user = find_for_oauth_by_uid(provider, uid)
      user.match_by = 'uid'
      return user
    end

    attributes = SocialProfile::Builder.new(provider, data).social_profile_attributes  # let this handle extracting the data
    email = attributes.email

    if email and user = @relation.where(email: email, invitation_token: nil).first
      user.match_by = 'email'
      return user
    end
  end

  def find_for_oauth_by_uid(provider, uid)
    @relation.where('authorizations.uid = ? AND authorizations.provider = ?', uid.to_s, provider).joins(:authorizations).readonly(false).first
  end
end