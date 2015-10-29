class ProjectDecorator < BaseArticleDecorator
  def components_for_buy_all
    @components_for_buy_all ||= model.part_joins.hardware.map{|pj| "#{pj.quantity} x #{pj.part.name}" }
  end
end
