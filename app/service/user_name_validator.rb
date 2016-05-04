class UserNameValidator
  ATTRIBUTES = %i(user_name new_user_name).freeze
  EXCLUDED_VALUES = %w(projects terms privacy admin infringement_policy search users communities hackerspaces hackers lists products about store api talk).freeze
  attr_accessor :user

  def initialize user
    @user = user
  end

  def valid?
    validate
    ATTRIBUTES.select do |attribute|
      user.errors[attribute].any?
    end.empty?
  end

  def validate
    validate_presence
    validate_format
    validate_exclusion
    validate_uniqueness
  end

  private
    def validate_presence
      return unless user.persisted? and !user.invited_to_sign_up?

      ATTRIBUTES.each do |attribute|
        user.errors.add attribute, 'is required' unless user.send(attribute).present?
      end
    end

    def validate_format
      ATTRIBUTES.each do |attribute|
        value = user.send(attribute)
        next if value.blank?

        user.errors.add attribute, 'has to be between 2 and 100 characters' if value.size < 2 or value.size > 100
        user.errors.add attribute, "accepts only letters, numbers, underscores '_' and dashes '-'." unless value =~ /\A[a-zA-Z0-9_\-]+\z/
      end
    end

    def validate_exclusion
      ATTRIBUTES.each do |attribute|
        value = user.send(attribute)

        user.errors.add attribute, "is not allowed to be equal to '#{value}'" if value.in? EXCLUDED_VALUES
      end
    end

    def validate_uniqueness
      return if user.user_name.blank? or user.being_invited?

      slug = SlugHistory.where("LOWER(slug_histories.value) = ?", user.new_user_name.downcase).first
      if slug and slug.sluggable != user
        ATTRIBUTES.each do |attribute|
          user.errors.add attribute, 'is already taken'
        end
      end
    end
end