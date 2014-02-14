class Promotion < Community
  belongs_to :course, foreign_key: :parent_id
  has_many :assignments, dependent: :destroy

  validates :user_name, uniqueness: { scope: [:type, :parent_id] }

  def projects
    Project.where(assignment_id: Assignment.where(promotion_id: id))
  end
end