class Promotion < Community
  belongs_to :course, foreign_key: :parent_id
  has_many :assignments, dependent: :destroy

  def projects
    Project.where(assignment_id: Assignment.where(promotion_id: id))
  end

  def generate_user_name
    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    self.user_name = slug
  end
end