class ListDecorator < GroupDecorator

  def facebook_description
    model.mini_resume + ' ' + if model.category?
      "Discover #{model.name} hardware projects."
    else
      "Discover hardware projects curated by #{model.name}."
    end
  end

  def facebook_title
    if model.category?
      "#{model.name} hardware projects"
    else
      "#{model.name}'s favorite hardware projects"
    end
  end

  def twitter_description
    if model.category?
      "#{model.mini_resume}"
    else
      "#{model.mini_resume}"
    end
  end

  def twitter_title
    if model.category?
      "#{model.name} hardware projects"
    else
      "#{model.name}'s favorite hardware projects"
    end
  end
end