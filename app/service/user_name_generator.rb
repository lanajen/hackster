class UserNameGenerator
  BASE_USER_NAME = "user"

  attr_accessor :user_name

  def initialize base=nil
    @user_name = generate_user_name(base)
  end

  private
    def format_as_user_name text
      I18n.transliterate(text).gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    end

    def generate_user_name base=nil
      if base.present?
        user_name = format_as_user_name base
        while SlugHistory.where(value: user_name).exists?
          user_name = format_as_user_name(base) + rand(1..2).times.map{rand(9) }.join('')
        end
        user_name
      else
        user_name_with_numbers = get_number_version(BASE_USER_NAME)
        while SlugHistory.where(value: user_name_with_numbers).exists?
          user_name_with_numbers = get_number_version(BASE_USER_NAME)
        end

        user_name_with_numbers
      end
    end

    def get_number_version base_user_name
      numbers = rand(5..10).times.map{ rand(9) }.join('')
      "#{base_user_name}#{numbers}"
    end
end