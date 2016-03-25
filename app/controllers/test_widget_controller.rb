class TestWidgetController < ApplicationController

  def index
    @username = current_user.inspect
    @project_count = current_user.projects_count
  end

end