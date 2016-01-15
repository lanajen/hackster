class ReviewDecisionJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id user_id approved decision))
    if model.rejection_reason.present?
      node[:rejection_reason] = model.decorate.rejection_reason
    end
    user = model.user
    node[:avatarLink] = user.decorate.avatar(:mini)
    node[:userName] = user.name
    node[:userSlug] = user.user_name
    node[:userRole] = user.is?(:admin, :hackster_moderator) ? :hackster : (user.is?(:moderator) ? :moderator : nil)
    node[:createdAt] = model.created_at.to_f * 1_000
    node[:feedback] = model.feedback.present? ? model.feedback : {}
    node
  end
end