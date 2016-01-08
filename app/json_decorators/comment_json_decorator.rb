class CommentJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id body user_id parent_id raw_body deleted))
    node[:avatarLink] = (model.user_id.zero? or model.user_id == -1) ? h.asset_path('guest_default_100.png') : model.user.decorate.avatar(:mini)
    node[:userName] = model.user_id.zero? ? model.guest_name : (model.user_id == -1 ? nil : model.user.name)
    node[:userSlug] = (model.user_id.zero? or model.user_id == -1) ? nil : model.user.user_name
    node[:depth] = model.is_root? ? 0 : 1
    node[:createdAt] = model.created_at.to_f * 1_000
    node[:likingUsers] = model.likes.map(&:user_id) || []
    node
  end
end