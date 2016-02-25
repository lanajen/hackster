json.extract! comment, :id, :user_id, :commentable_id, :commentable_type, :parent_id, :body
json.set! :avatarLink, comment.user_id.zero? ? image_tag('guest_default_100.png') : comment.user.decorate.avatar_link(:mini)
json.set! :userName, comment.user_id.zero? ? comment.guest_name : comment.user.id == -1 ? '<span>Deleted User</span>' : comment.user.decorate.name_link
json.set! :depth, comment.is_root? ? 0 : 1
json.set! :createdAt, comment.created_at
json.set! :deleted, comment.deleted