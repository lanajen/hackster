class CommentJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id user_id commentable_id commentable_type parent_id body deleted))
    node[:avatarLink] = (model.user_id.zero? or model.user_id == -1) ? h.image_tag('guest_default_100.png') : model.user.decorate.avatar_link(:mini)
    node[:userName] = model.user_id.zero? ? model.guest_name : model.user_id == -1 ? '<span>Deleted user</span>' : model.user.decorate.name_link
    node[:depth] = model.is_root? ? 0 : 1
    node[:createdAt] = model.created_at
    node
  end
end