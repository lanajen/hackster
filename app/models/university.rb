class University < Group
  has_many :courses_universities
  has_many :courses, through: :courses_universities
  before_create :generate_user_name
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
end
