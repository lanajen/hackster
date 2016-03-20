class ReviewDecisionJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id user_id approved decision))
    if model.rejection_reason.present?
      node[:rejection_reason] = model.decorate.rejection_reason
    end
    user = model.user
    node[:avatarLink] = user ? user.decorate(decorator_context).avatar(:mini) : h.asset_path('guest_default_100.png')
    node[:userName] = user ? user.name : 'Deleted account'
    node[:userSlug] = user ? user.user_name : ''
    node[:userRole] = user ? (%w(admin hackster_moderator super_moderator moderator) & user.roles).first : nil
    node[:createdAt] = model.created_at.to_f * 1_000
    node[:feedback] = model.feedback.present? ? model.feedback : {}
    node
  end
end