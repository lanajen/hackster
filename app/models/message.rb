class Message

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :from_email, :to_email, :subject, :body, :message_type

  validates :name, :email, :subject, :body, :presence => true
  validates :email, :format => { :with => %r{.+@.+\..+} }, :allow_blank => true

  def email=(value)
    self.from_email = value
  end

  def email
    from_email
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end