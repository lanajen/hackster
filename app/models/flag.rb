class Flag
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_id, :flaggable_id, :flaggable_type

  validates :flaggable_id, :flaggable_type, presence: true

  def initialize attributes={}
    attributes.each do |attribute, value|
      send "#{attribute}=", value
    end
  end

  def flaggable
    return unless flaggable_id and flaggable_type

    @flaggable ||= flaggable_type.constantize.find_by_id(flaggable_id)
  end

  def user
    return unless user_id

    @user ||= User.find_by_id(user_id)
  end
end