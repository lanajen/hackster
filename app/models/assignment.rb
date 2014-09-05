class Assignment < ActiveRecord::Base
  GRADING_TYPES = {
    'One grade per student' => 'individual',
    'A single grade per team' => 'group',
  }

  belongs_to :promotion
  has_many :grades, through: :projects
  has_many :projects, foreign_key: :collection_id
  has_one :document, as: :attachable, dependent: :destroy
  validates :promotion_id, :name, presence: true
  attr_accessible :name, :document_id, :grading_type, :graded, :private_grades

  before_create :generate_id

  def document_id=(val)
    self.document = Document.find_by_id(val)
  end

  def graded?
    graded
  end

  def to_csv
    out = "project_name,project_url,grade,student_names,student_emails\r\n"

    grades.each do |grade|
      out << "\"#{grade.project.name}\",\"http://hackster.io/#{grade.project.uri}\",\"#{grade.grade}\",\"#{grade.project.users.map{|u| u.name}.join(',')}\",\"#{grade.project.users.map{|u| u.email}.join(',')}\"\r\n"
    end
    out
  end

  def to_label
    "#{promotion.name} / #{name}"
  end

  private
    def generate_id
      self.id_for_promotion = promotion.assignments.size + 1
    end
end
