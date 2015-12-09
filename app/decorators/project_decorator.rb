class ProjectDecorator < BaseArticleDecorator
  def certified?
    model.project_collections.certified.exists?
  end

  def certifier_names
    model.project_collections.certified.joins("INNER JOIN groups ON project_collections.collectable_id = groups.id AND project_collections.collectable_type = 'Group'").pluck("groups.full_name")
  end

  def components_for_buy_all
    @components_for_buy_all ||= model.part_joins.hardware.map{|pj| "#{pj.quantity} x #{pj.part.name}" }
  end
end