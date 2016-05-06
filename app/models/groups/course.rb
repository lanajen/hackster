class Course < Community
  belongs_to :university, foreign_key: :parent_id
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PromotionMember'
  has_many :promotions, foreign_key: :parent_id, dependent: :destroy
  validate :university_is_selected

  hstore_column :hproperties, :course_number, :string

  attr_accessible :parent_id

  def generate_user_name
    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    self.user_name = slug
  end

  def projects
    BaseArticle.joins(:project_collections).where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.joins(:promotion).where(groups: { parent_id: id }) })
  end

  def project_collections
    ProjectCollection.where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.joins(:promotion).where(groups: { parent_id: id }) })
  end

  private
    def university_is_selected
      errors.add :university, 'cannot be blank' if university.blank?
    end
end