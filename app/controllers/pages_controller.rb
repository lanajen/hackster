class PagesController < ApplicationController
  def home
    @featured_projects = Project.limit 4
    @last_projects = Project.order('created_at DESC').limit(4)
    if current_user
      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
    end
  end
end
