class Course < Community
  has_one :courses_university
  has_one :university, through: :courses_university
  has_many :promotions, foreign_key: :parent_id
  validate :university_is_selected

  def generate_user_name
    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    self.user_name = slug
  end

  def projects
    Project.where(assignment_id: Assignment.joins(:promotion).where(groups: { parent_id: id }))
  end

  private
    def university_is_selected
      errors.add :university, 'cannot be blank' if university.blank?
    end
end