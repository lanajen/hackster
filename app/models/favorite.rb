class Favorite < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_accessible :project_id, :user_id
  validates :user_id, uniqueness: { scope: :project_id }
end
