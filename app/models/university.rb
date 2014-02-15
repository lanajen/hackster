class University < Group
  has_many :courses_universities
  has_many :courses, through: :courses_universities
end
