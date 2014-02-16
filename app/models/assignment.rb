class Assignment < ActiveRecord::Base
  belongs_to :promotion
  has_many :projects
  has_one :document, as: :attachable, dependent: :destroy
  validates :promotion_id, :name, presence: true
  attr_accessible :name, :document_id

  before_create :generate_id

  def document_id=(val)
    self.document = Document.find_by_id(val)
  end

  def to_label
    "#{promotion.course.name} @#{promotion.course.university.full_name} > #{promotion.name} > #{name}"
  end

  private
    def generate_id
      self.id_for_promotion = promotion.assignments.size + 1
    end
end
