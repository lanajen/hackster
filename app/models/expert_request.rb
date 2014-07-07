class ExpertRequest
  AREAS_OF_EXPERTISE = [
    'Mechanical and electrical engineering',
    'Software engineering',
    'Industrial design',
    'Crowdfunding',
    'Business model and strategy',
    'Sourcing',
    'Manufacturing',
    'Distribution',
  ]

  BUDGETS = [
    '$0',
    '$1-$1,000',
    '$1,001-$10,000',
    '$10,001+'
  ]

  STAGES = [
    'I just have an idea',
    'I have a prototype',
    'I have a product being sold',
  ]

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :project_id, :project_description, :stage, :expertise_area,
    :request_description, :budget, :comments, :name, :email, :phone, :location

  validates :stage, :expertise_area, :request_description, presence: true
  validate :project_id_or_description_is_present?

  def expertise_area
    @expertise_area.select{|v| v.present?} if @expertise_area
  end

  def initialize attributes={}
    attributes.each do |attribute, value|
      send "#{attribute}=", value
    end
  end

  private
    def project_id_or_description_is_present?
      errors.add :project_description, 'is required' if project_id.blank? and project_description.blank?
    end
end