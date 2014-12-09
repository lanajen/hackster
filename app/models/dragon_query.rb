class DragonQuery
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  PRODUCT_CATEGORIES = ['3D Printer / Scanner', 'Auto', 'Baby', 'Bike',
    'Controller / PCBA', 'Drone', 'Education', 'Exercise',
    'Game or Haptic Controller', 'Home Automation', 'Pet',
    'Phone, Tablet or Computer Accessory', 'Quantified Self', 'Robot', 'Sensor',
    'Solar / Wind', 'Tool', 'Toy', 'Vehicle', 'Wearable', 'Other', 'Audio',
    'Connected Devices', 'Electronics', 'Fashion', 'Food', 'Hardware', 'Media',
    'Music']

  STAGES_OF_DEVELOPMENT = ['Idea', 'Rendering', 'Mock-up / Proof of Concept',
    'CAD & Schematic', 'Working Prototype', 'Full DFM', 'In Production']

  TARGET_PRICES = ['Less than $20', '$20 - $49', '$50 - $99', '$100 - $199',
    'Above $200']

  DESIRED_INITIAL_VOLUMES = ['0 - 500 units', '500 - 1000 units',
    '1000 - 2500 units', '2500 - 5000 units', '5000+ units']

  LAUNCH_DATES = ['ASAP', 'Within a month', '1 - 2 months', '3+ months']

  SERVICES = ['Dragon certified', 'Manufacturing services', "I'm not sure"]

  attr_accessor :first_name, :last_name, :company, :email, :city, :state,
    :product_name, :product_category, :description, :stage_of_development,
    :target_price, :desired_initial_volume, :launch_date, :services

  validates :first_name, :last_name, :email, :product_name, :description,
    :stage_of_development, :target_price, :services, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def to_csv
    attributes = [:first_name, :last_name, :company, :email, :city, :state,
    :product_name, :product_category, :description, :stage_of_development,
    :target_price, :desired_initial_volume, :launch_date, :services]

    header = attributes.join(',') + "\n"

    out = header

    out << attributes.map do |attr|
      a = '"'

      value = send(attr)
      case value
      when Array
        a << value.select{|v| v.present? }.to_sentence
      else
        a << value.to_s
      end
      a << '"'

      a
    end.join(',') << "\n"

    out
  end
end