#autoload 'widgets'

class Widget < ActiveRecord::Base
  include Privatable

  belongs_to :widgetable, polymorphic: true
  validates :name, length: { maximum: 100 }

  attr_accessible :properties, :type, :name, :position, :project_id, :widgetable_id,
    :widgetable_type

  validates :type, presence: true

  def has_name?
    name.present? and name != 'Untitled'
  end

  def default_label
    nil
  end

  def embed_format
    nil
  end

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

  def to_text
    ''
  end

  def to_tracker
    {
      widget_id: id,
      widget_type: identifier,
    }
  end
end
