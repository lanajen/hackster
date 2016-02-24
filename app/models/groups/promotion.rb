class Promotion < Community
  belongs_to :course, foreign_key: :parent_id
  has_many :assignments, -> { order(:id_for_promotion) }, dependent: :destroy
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PromotionMember'

  alias_method :short_name, :name

  attr_accessible :parent_id

  def default_user_name
    short_name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase[0...100]
  end

  alias_method :old_name, :name

  def name
    "#{course.name} - #{super} @#{course.university.name}"
  end

  def proper_name
    "#{course.name} - #{old_name}"
  end

  def professor
    members.with_group_roles(:professor).includes(:user).first
  end

  def projects
    BaseArticle.joins(:project_collections).where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.where(promotion_id: id) })
  end

  def project_collections
    ProjectCollection.where(project_collections: { collectable_type: 'Assignment', collectable_id: Assignment.where(promotion_id: id) })
  end

  def university
    @university ||= course.try(:university)
  end
end