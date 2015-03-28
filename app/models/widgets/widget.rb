#autoload 'widgets'

class Widget < ActiveRecord::Base
  include Privatable

  belongs_to :widgetable, polymorphic: true
  # has_many :comments, as: :commentable, dependent: :destroy
  # has_many :issues, as: :threadable, dependent: :destroy
  validates :name, length: { maximum: 100 }

  attr_accessible :properties, :type, :name, :position, :project_id, :widgetable_id,
    :widgetable_type

  validates :type, :project_id, presence: true
  # before_create :set_position

  def default_label
    nil
  end

  def embed_format
    nil
  end

  # def has_unresolved_issues?
  #   issues.where(workflow_state: :unresolved).any?
  # end

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

  # def self.first_column
  #   column '1'
  # end

  # def self.second_column
  #   column '2'
  # end

  # def self.column col
  #   where("widgets.position LIKE '#{col}.%'")
  # end

  # def self.type_is type
  #   classes = case type
  #   when 'hardware'
  #     %w(PartsWidget CircuitsioWidget OshparkWidget StlWidget UpverterWidget)
  #   when 'software'
  #     %w(CodeWidget GithubWidget BitbucketWidget)
  #   end
  #   where(type: classes)
  # end

  # def column
  #   position.match(/^./)[0].to_i
  # end

  def identifier
    self.class.name.to_s.underscore
  end

  def help_text
    ''
  end

  # retro-compatibility
  def project
    widgetable
  end

  def project=(val)
    self.widgetable = val
  end

  def project_id
    widgetable_id
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

  # def row
  #   position.match(/\.(.+)$/)[1].to_i
  # end

  # def to_error
  #   errors.messages
  # end

  def to_text
    ''
  end

  def to_tracker
    {
      widget_id: id,
      widget_type: identifier,
    }
  end

  # protected
    # def self.all_types
    #   {
    #     'Bill of materials' => 'PartsWidget',
    #     # 'Bitbucket repo' => 'BitbucketWidget',
    #     # 'Build log' => 'BuildLogWidget',
    #     # 'Buy now' => 'BuyWidget',
    #     # 'Circuits.io schematics' => 'CircuitsioWidget',
    #     'Code' => 'CodeWidget',
    #     # 'Credits' => 'CreditsWidget',
    #     # 'Files and documents' => 'DocumentWidget',
    #     # 'Github repo' => 'GithubWidget',
    #     # 'Images' => 'ImageWidget',
    #     # 'Issues' => 'IssuesWidget',
    #     # 'OSH Park shared project' => 'OshparkWidget',
    #     # 'PayPal Buy Now button' => 'PaypalWidget',
    #     # 'Press articles' => 'PressWidget',
    #     # 'STL renderings' => 'StlWidget',
    #     'Step by step guide' => 'StepByStepWidget',
    #     # 'Text' => 'TextWidget',
    #     # 'Upverter schematics' => 'UpverterWidget',
    #     # 'Video' => 'VideoWidget',
    #   }
    # end

  private
    def set_position
      columns_count = project.columns_count
      last_widget = nil
      biggest_row = 0
      project.widgets.each do |w|
        if biggest_row <= w.row
          last_widget = w
          biggest_row = w.row
        end
      end
      if last_widget
        column = columns_count == 1 ? 1 : (last_widget.column == 1 ? 2 : 1)
        row = project.widgets.column(column).try(:last).try(:row).to_i + 1
        row = "0#{row}" if row < 10
      else
        column, row = 1, '01'
      end
      self.position = "#{column}.#{row}"
    end
end
