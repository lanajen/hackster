#autoload 'widgets'

class Widget < ActiveRecord::Base
  belongs_to :stage
  has_many :issues, as: :threadable, dependent: :destroy

  def has_unresolved_issues?
    issues.where(workflow_state: :unresolved).any?
  end

  attr_accessible :properties, :stage_id, :type, :completion_rate,
    :completion_share, :name

  validates :completion_rate, :completion_share,
    numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0,
    only_integer: true }
  validates :type, :name, presence: true
  validate :total_completion_is_100_max

  class << self
    attr_accessor :custom_attributes

    def define_attributes attributes
      self.custom_attributes = []
      attributes.each do |attribute|
        self.custom_attributes += [attribute]
        send :attr_accessible, attribute
        send :define_method, "#{attribute}=" do |val|
          prop = properties
          prop[attribute] = val
          self.properties = prop
        end
        send :define_method, attribute do
          properties[attribute]
        end
        send :define_method, "#{attribute}_was" do
          properties_was[attribute] if properties_was
        end
        send :define_method, "#{attribute}_changed?" do
          send("#{attribute}_was") != send(attribute)
        end
      end
    end
  end

  def completion_absolute
    completion_share * completion_rate / 100
  end

  def identifier
    self.class.name.to_s.underscore
  end

  def help_text
    ''
  end

  def project
    stage.project
  end

  def properties
    val = read_attribute :properties
    val.present? ? YAML::load(val) : {}
  end

  def properties=(val)
    write_attribute :properties, YAML::dump(val)
  end

  def properties_was
    val = super
    val.kind_of?(String) ? YAML::load(val) : val
  end

  def public?
    private == false
  end
  
  attr_accessible :private, :privacy_rules_attributes
  has_many :privacy_rules, as: :privatable
  accepts_nested_attributes_for :privacy_rules, allow_destroy: true

  def visible_to? user
    public? or user.has_access_group_permissions? self or user.is_team_member? project
  end

  protected
    def self.all_types
      {
        'Code' => 'CodeWidget',
        'Documents' => 'DocumentWidget',
        'Images' => 'ImageWidget',
        'Text' => 'TextWidget',
        'Video' => 'VideoWidget',
      }
    end

  private
    def total_completion_is_100_max
      total_completion = stage.widgets.where('widgets.id <> ?', id).sum(:completion_share) + completion_share
      errors.add :completion_share, "total completion share for the stage cannot be higher than 100. Current: #{total_completion}" if total_completion > 100
    end
end
