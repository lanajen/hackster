class PartImpression < ActiveRecord::Base
  belongs_to :part
  belongs_to :user

  after_create :increment_counter_cache

  private
    def increment_counter_cache
      Part.increment_counter :impressions_count, part_id unless part.impressions.where.not(id: id).where(session_hash: session_hash).exists?
    end
end
