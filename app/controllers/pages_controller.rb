class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:splash]

  def help
  end

  def home
    @featured_projects = Project.where(private: false).limit 4
    @last_projects = Project.where(private: false).order('created_at DESC').limit(4)
    if current_user
      @custom_projects_query = current_user.interest_tags.pluck(:name).join(' OR ')
      @custom_projects = @custom_projects_query.present? ? SearchRepository.new(query: @custom_projects_query, model: { project: 1 }, size: 4).search.results : []
    end
  end

  def splash
    render layout: false
  end
end
