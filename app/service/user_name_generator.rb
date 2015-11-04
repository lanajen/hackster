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

      last = User.select('users.user_name').where("users.user_name ILIKE '#{random_user_name}-%'").order(:created_at).last

      count = last ? last.user_name.split(/-/).last.to_i : 0

      "#{random_user_name}-#{count + 1}"
    end
end