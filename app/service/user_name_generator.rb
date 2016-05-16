class UserNameGenerator
  BASE_USER_NAME = "user"

  attr_accessor :user_name

  def initialize
    @user_name = generate_user_name
  end

  private
    def generate_user_name
      user_name_with_numbers = get_number_version(BASE_USER_NAME)
      while SlugHistory.where(value: user_name_with_numbers).exists?
        user_name_with_numbers = get_number_version(BASE_USER_NAME)
      end

      user_name_with_numbers
    end

    def get_number_version base_user_name
      numbers = rand(5..10).times.map{ rand(9) }.join('')
      "#{base_user_name}#{numbers}"
    end
end