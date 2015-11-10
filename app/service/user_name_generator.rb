class UserNameGenerator
  USER_NAME_WORDS_LIST1 = %w(acid ada agent alien chell colossus crash cyborg doc ender enigma hal isambard jarvis kaneda leela morpheus neo nikola oracle phantom radio silicon sim starbuck straylight synergy tank tetsuo trinity zero)
  USER_NAME_WORDS_LIST2 = %w(algorithm blue brunel burn clone cool core curie davinci deckard driver energy fett flynn formula gibson glitch grid hawking jaunte newton overdrive override phreak plasma ripley skywalker tesla titanium uhura wiggin)

  attr_accessor :user_name

  def initialize
    @user_name = generate_user_name
  end

  private
    def generate_random_user_name
      "#{USER_NAME_WORDS_LIST1.sample}-#{USER_NAME_WORDS_LIST2.sample}"
    end

    def generate_user_name
      random_user_name = generate_random_user_name

      user_name_with_hex = get_hex_version(random_user_name)
      while SlugHistory.where(value: user_name_with_hex).exists?
        user_name_with_hex = get_hex_version(random_user_name)
      end

      user_name_with_hex
    end

    def get_hex_version random_user_name
      hex = SecureRandom.hex(3)
      "#{random_user_name}-#{hex}"
    end
end