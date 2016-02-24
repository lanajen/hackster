class PromotionDecorator < GroupDecorator
  def location
    univ = model.university
    return unless univ

    univ.decorate.location
  end
end