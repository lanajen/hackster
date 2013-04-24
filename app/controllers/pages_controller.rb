class PagesController < ApplicationController
  def home
    @featured_projects = Project.limit 4
  end
end
