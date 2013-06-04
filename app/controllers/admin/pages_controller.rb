class Admin::PagesController < Admin::BaseController
  def logs
    redirect_to admin_logs_path(page: (LogLine.count.to_f / LogLine.per_page).ceil) unless params[:page]
    @log_lines = LogLine.order(:created_at).paginate(page: params[:page])
  end

  def root
  end
end
