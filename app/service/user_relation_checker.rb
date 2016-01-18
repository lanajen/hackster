class UserRelationChecker
  attr_accessor :user

  def initialize user
    @user = user
  end

  # check if the user is a platform moderator of a platform associated with the
  # given project
  def is_platform_moderator? project
    PlatformMember
      .where(user_id: user.id)
      .joins(group: :project_collections)
      .merge(Platform.moderation_enabled)
      .where(project_collections: { project_id: project.id })
      .with_group_roles([:admin, :hackster_moderator])
      .exists?
  end
end