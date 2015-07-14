class Quote
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :project_id, :components, :email, :country

  validates :project_id, :country, presence: true
  validates :email, format: EMAIL_REGEXP
  validate :validates_has_components

  def initialize attributes={}
    attributes.each do |attribute, value|
      send "#{attribute}=", value
    end
  end

  def project
    return unless project_id

    @project ||= Project.find_by_id(project_id)
  end

  private
    def validates_has_components
      errors.add :components, "you must select at least one component" unless (components and components.is_a?(Array) and components.select{|v| v.present? }.any?)
    end
end