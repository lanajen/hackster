class CommentJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id body user_id parent_id raw_body deleted))
    if model.user_id != 0 and model.user_id != -1
      user = model.user
      node[:userRole] = (%w(admin hackster_moderator super_moderator moderator) & user.roles).first
      node[:userLink] = url.user_path(user)
    end
    node[:avatarLink] = (model.user_id.zero? or model.user_id == -1) ? h.asset_path('guest_default_100.png') : user.decorate(decorator_context).avatar(:mini)
    node[:userName] = model.user_id.zero? ? model.guest_name : (model.user_id == -1 ? nil : user.name)
    node[:userSlug] = (model.user_id.zero? or model.user_id == -1) ? nil : user.user_name
    node[:depth] = model.is_root? ? 0 : 1
    node[:createdAt] = model.created_at.to_f * 1_000
    node[:likingUsers] = model.likes.map(&:user_id) || []
    node
  end
end