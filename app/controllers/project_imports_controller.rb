class ProjectImportsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  def create
    if params[:urls].present?
      Resque.enqueue ScraperQueue, 'scrape_projects', params[:urls], params[:user_id] || current_user.id
      redirect_to new_project_import_path, notice: "We will start importing your projects soon. You'll receive an email when it's done."
    else
      flash.now[:alert] = "Please specify at least one page to import."
      render action: 'new'
    end
  end

  def submit
    if params[:url].present?
      @message = Message.new(
        from_email: current_user.email,
        message_type: 'generic'
      )
      @message.subject = "New import request"
      @message.body = "<p>Hi</p><p>Please import this project for me: <a href='#{params[:url]}'>#{params[:url]}</a>.</p><p>Thanks!<br><a href='#{url_for(current_user)}'>#{current_user.name}</a></p><p><a href='http://#{APP_CONFIG['full_host']}/projects/imports/new'>Start importing</a></p>"
      BaseMailer.enqueue_generic_email(@message)
      redirect_to new_project_path, notice: "We will start importing your project soon. You'll receive an email when it's done."
    else
      redirect_to new_project_path, alert: "Please specify a page to import."
    end
  end
end