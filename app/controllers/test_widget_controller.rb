class TestWidgetController < ApplicationController

  def index
    @username = current_user.user_name
    @project_count = current_user.projects_count

  end

end

