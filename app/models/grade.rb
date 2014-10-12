class Grade < ActiveRecord::Base
  # has_one :assignment, through: :project
  belongs_to :gradable, polymorphic: true
  belongs_to :project
  belongs_to :user

  validates :grade, presence: true#, length: { in: 1..3 }

  def assignment
    project.assignment
  end

  def private?
    assignment.private_grades
  end
end
