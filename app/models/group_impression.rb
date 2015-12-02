class GroupImpression < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  after_create :increment_counter_cache

  private
    def increment_counter_cache
      Group.increment_counter :impressions_count, group_id unless group.impressions.where.not(id: id).where(session_hash: session_hash).exists?
    end
end
