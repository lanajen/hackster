#autoload 'widgets'

class Widget < ActiveRecord::Base
  belongs_to :stage

  attr_accessible :properties, :stage_id, :type, :completion_rate,
    :completion_share, :name

  validates :completion_rate, :completion_share, numericality: { in: 0..100,
    only_integer: true }
  validates :type, :name, presence: true

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

  protected
    def self.all_types
      {
        'Images' => 'ImageWidget',
        'Text' => 'TextWidget',
        'Video' => 'VideoWidget',
      }
    end
end
