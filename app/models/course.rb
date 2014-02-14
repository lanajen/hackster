class Course < Community
  has_many :promotions, foreign_key: :parent_id

  def projects
    Project.where(assignment_id: Assignment.joins(:promotion).where(groups: { parent_id: id }))
  end
end