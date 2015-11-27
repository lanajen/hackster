class ProjectImpression < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  after_create :increment_counter_cache

  private
    def increment_counter_cache
      Project.increment_counter :impressions_count, project_id unless project.impressions.where.not(id: id).where(session_hash: session_hash).exists?
    end
end
