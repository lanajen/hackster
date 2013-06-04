#autoload 'widgets'

class Widget < ActiveRecord::Base
  include Privatable

  belongs_to :project
  belongs_to :stage
  has_many :issues, as: :threadable, dependent: :destroy

  def has_unresolved_issues?
    issues.where(workflow_state: :unresolved).any?
  end

  attr_accessible :properties, :stage_id, :type, :completion_rate,
    :completion_share, :name, :position

#  validates :completion_rate, :completion_share,
#    numericality: { less_than_or_equal_to: 100, greater_than_or_equal_to: 0,
#    only_integer: true }
  validates :type, :name, presence: true
  before_create :set_position
#  validate :total_completion_is_100_max

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

  def self.first_column
    column '1'
  end

  def self.second_column
    column '2'
  end

  def self.column col
    where("widgets.position LIKE '#{col}.%'")
  end

  def column
    position.match(/^./)[0].to_i
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

#  def project
#    stage.project
#  end

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

  def row
    position.match(/\.(.+)$/)[1].to_i
  end

  protected
    def self.all_types
      {
        'Bill of materials' => 'PartsWidget',
        'Code' => 'CodeWidget',
        'Files and documents' => 'DocumentWidget',
        'Images' => 'ImageWidget',
        'STL renderings' => 'StlWidget',
        'Text' => 'TextWidget',
        'Upverter schematics' => 'UpverterWidget',
        'Video' => 'VideoWidget',
      }
    end

  private
    def set_position
      last_widget = nil
      biggest_row = 0
      project.widgets.each do |w|
        if biggest_row <= w.row
          last_widget = w
          biggest_row = w.row
        end
      end
      if last_widget
        column = last_widget.column == 1 ? 2 : 1
        row = project.widgets.column(column).try(:last).try(:row).to_i + 1
        row = "0#{row}" if row < 10
      else
        column, row = 1, 1
      end
      self.position = "#{column}.#{row}"
    end

    def total_completion_is_100_max
      total_completion = stage.widgets.where('widgets.id <> ?', id).sum(:completion_share) + completion_share
      errors.add :completion_share, "total completion share for the stage cannot be higher than 100. Current: #{total_completion}" if total_completion > 100
    end
end
