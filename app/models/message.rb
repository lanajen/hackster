class Message

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :from_email, :to_email, :subject, :body, :message_type,
    :recipients

  validates :name, :email, :subject, :body, presence: true
  validates :email, format: { :with => %r{.+@.+\..+} }, allow_blank: true
#  validate :recipients_is_not_blank
#  validate :no_more_than_100_recipients

  def email=(value)
    self.from_email = value
  end

  def email
    from_email
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end if attributes
  end

  def persisted?
    false
  end

  private
    def no_more_than_100_recipients
      return if recipients.blank?
      clean_recipients = recipients.split(/(\s+|;)/)
      clean_recipients = clean_recipients.select { |e| e.match(/^\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b$/) }
      errors.add :recipients, 'is limited to 100' if clean_recipients.size > 100
    end

    def recipients_is_not_blank
      # let it be nil but not blank
      errors.add :recipients, I18n.t('errors.messages.blank') if recipients.blank? and not recipients.nil?
    end
end