class ReviewEventJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id user_id))
    if model.user
      node[:userRole] = (%w(admin hackster_moderator super_moderator moderator) & model.user.roles).first
    end
    node[:avatarLink] = model.user.try(:decorate).try(:avatar, :mini)
    node[:userName] = model.user.try(:name)
    node[:userSlug] = model.user.try(:user_name)
    node[:message] = model.decorate.message
    node[:createdAt] = model.created_at.to_f * 1_000
    node
  end
end