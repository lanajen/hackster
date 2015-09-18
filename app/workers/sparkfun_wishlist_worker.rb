class SparkfunWishlistWorker < BaseWorker
  sidekiq_options queue: :critical, retry: 0

  def import project_id, wishlist_id, user_id=nil
    project = Project.find project_id
    wishlist = SparkfunWishlist.new wishlist_id
    if wishlist.has_parts?
      seed_project_with_wishlist project, wishlist
      assign_project_to_user project, user_id if user_id
    end
  end

  private
    def assign_project_to_user project, user_id
      project.build_team
      project.team.members.new user_id: user_id
      project.save
    end

    def seed_project_with_wishlist project, wishlist
      wishlist.parts.each do |part, quantity|
        project.part_joins.new part_id: part.hackster_part.id, quantity: quantity
      end
      project.name = wishlist.name if project.name.blank? and wishlist.name.present?
      project.description = wishlist.description if project.description.blank? and wishlist.description.present?

      project.save
    end
end