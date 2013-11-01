class LogLine < ActiveRecord::Base
  belongs_to :loggable, polymorphic: true

  attr_accessible :log_type, :message, :source, :loggable_id, :loggable_type

  self.per_page = 20

  # marshaling objects
  [:message].each do |attribute|
    define_method "#{attribute}=" do |val|
      write_attribute attribute, Base64.encode64(Marshal.dump(val))
    end
    define_method attribute do
      begin
        value = read_attribute attribute
        return Marshal.load(Base64.decode64(value)) if value
      rescue => e
        Rails.logger.info e.inspect
      end
      "Couldn't read value"
    end
  end
end
