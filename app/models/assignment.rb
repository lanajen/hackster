class Assignment < ActiveRecord::Base
  belongs_to :promotion
  has_many :projects
  validates :promotion_id, presence: true

  before_create :generate_id

  def to_label
    "#{promotion.course.name} > #{promotion.name} > #{name}"
  end

  private
    def generate_id
      self.id_for_promotion = promotion.assignments.size + 1
    end
end
