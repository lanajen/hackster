class ListDecorator < GroupDecorator

  def facebook_description
     "#{model.mini_resume} #{add_curated_by_to("Discover hardware projects in '#{model.name}'")}"
  end

  def facebook_title
    add_curated_by_to "Hardware projects in '#{model.name}'"
  end

  def twitter_description
    "#{model.mini_resume}"
  end

  alias_method :twitter_title, :facebook_title

  private
    def add_curated_by_to text
      text += ", curated by #{model.team_members.first.user.name}" if model.team_members_count > 0
      text
    end
end