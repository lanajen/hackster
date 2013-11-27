class Email
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :from_email, :to_email, :subject, :body, :message_type, :platform_id,
    :recipients

  validates :name, :email, :subject, :body, presence: true
  validates :email, format: { with: /\A\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b\z/ }, allow_blank: true
  validate :recipients_is_not_blank

  TEMPLATE_DIRECTORY = File.join(Rails.root, 'app', 'views', 'mailers')

  def self.find_by_type type, conditions={}
    conditions.merge!(message_type: type)
    find_in_file_system(conditions)
  end

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

  private
    def self.find_in_file_system conditions
      file_name = "#{conditions[:message_type]}.html.erb"
      subject = FileResolver.read_file(File.join(TEMPLATE_DIRECTORY, 'subjects', file_name))
      body = FileResolver.read_file(File.join(TEMPLATE_DIRECTORY, 'bodies', file_name))
      if subject and body
        return new subject: subject, body: body, message_type: conditions[:message_type]
      end
    end

    def recipients_is_not_blank
      # let it be nil but not blank
      errors.add :recipients, 'cannot be blank' if recipients.blank? and not recipients.nil?
    end
end
