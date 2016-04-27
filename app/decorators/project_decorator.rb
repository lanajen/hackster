class ProjectDecorator < BaseArticleDecorator
  def certified? only_name_allowed=nil
    certifier_names(only_name_allowed).any?
  end

  def certifier_names only_name_allowed=nil
    only_name_allowed ? (model.certifier_names & [only_name_allowed]) : model.certifier_names
  end

  def components_for_buy_all
    @components_for_buy_all ||= model.part_joins.hardware.map{|pj| "#{pj.quantity} x #{pj.part.name}" }
  end
end