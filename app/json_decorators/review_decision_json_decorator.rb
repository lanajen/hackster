class ReviewDecisionJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id user_id approved decision))
    if model.rejection_reason.present?
      node[:rejection_reason] = model.decorate.rejection_reason
    end
    node[:avatarLink] = model.user.decorate.avatar(:mini)
    node[:userName] = model.user.name
    node[:userSlug] = model.user.user_name
    node[:createdAt] = model.created_at.to_f * 1_000
    node[:feedback] = model.feedback.present? ? model.feedback : {}
    node
  end
end