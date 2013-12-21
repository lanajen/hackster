class ProjectImportsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  def create
    if params[:url].present?
      Resque.enqueue ScraperQueue, 'scrape_project', params[:url], current_user.id
      redirect_to new_project_import_path, notice: "We will start importing your project soon. You'll receive an email when it's done."
    else
      flash.now[:alert] = "Please specify a page to import."
      render action: 'new'
    end
  end
end