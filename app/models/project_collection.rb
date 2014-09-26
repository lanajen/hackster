class ProjectCollection < ActiveRecord::Base
  belongs_to :collectable, polymorphic: true
  belongs_to :project

  # validate :ensure_has_collectable
  validates :project_id, uniqueness: { scope: [:collectable_id, :collectable_type] }

  private
    def ensure_has_collectable
      destroy if collectable_type.blank? or collectable_id.blank? or project_id.blank?
    end
end
