class ListDecorator < GroupDecorator

  def facebook_description
    model.mini_resume + ' ' + if model.category?
      "Discover #{model.name} hardware projects and hacks."
    else
      "Discover hardware projects and hacks curated by #{model.name}."
    end
  end

  def facebook_title
    if model.category?
      "#{model.name} hardware hacks"
    else
      "#{model.name}'s favorite hardware hacks"
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
      "#{model.name} hardware hacks"
    else
      "#{model.name}'s favorite hardware hacks"
    end
  end
end