class PagesController < ApplicationController

  def help
  end

  def home
    @featured_projects = Project.indexable.featured.limit 4
    @last_projects = Project.indexable.order('created_at DESC').limit(4)
    @last_updated_projects = Project.indexable.order('updated_at DESC').limit(4)
#    if user_signed_in?
#      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
#      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
#    end
  end
end
