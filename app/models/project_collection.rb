class ProjectCollection < ActiveRecord::Base
  belongs_to :collectable, polymorphic: true
  belongs_to :project

  validates :project_id, uniqueness: { scope: [:collectable_id, :collectable_type] }
end
