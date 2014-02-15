class University < Group
  has_many :courses_universities
  has_many :courses, through: :courses_universities
  before_validation :generate_user_name

  def generate_user_name
    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    self.user_name = slug
  end
end
