class UserNameGenerator
  BASE_USER_NAME = "user"

  attr_accessor :user_name

  def initialize base=nil
    @user_name = generate_user_name(base)
  end

  private
    def base_user_name base=nil
      if _name = format_as_user_name(base) and _name.present?
        return _name, 1..3
      else
        return BASE_USER_NAME, 5..10
      end
    end

    def format_as_user_name text
      return unless text.present?

      I18n.transliterate(text).gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
    end

    def generate_user_name base=nil
      _base, nums = base_user_name(base)
      _name = _base.dup
      while SlugHistory.where(value: _name).exists?
        _name = get_number_version(_base, nums)
      end
      _name
    end

    def get_number_version base, nums
      numbers = rand(nums).times.map{ rand(9) }.join('')
      "#{base}#{numbers}"
    end
end