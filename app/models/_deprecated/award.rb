class Award < Grade
  # attr_accessible :prize
  before_validation :set_project_id

  def name
    grade
  end

  def name=(val)
    self.grade = val
  end

  def prize
    feedback
  end

  def prize=(val)
    self.feedback = val
  end

  private
    def set_project_id
      self.project_id = 0 unless project_id
    end
end