class Admin::PagesController < Admin::BaseController
  include FilterHelper

  def logs
    redirect_to admin_logs_path(page: (LogLine.count.to_f / LogLine.per_page).ceil) unless params[:page]

    @fields = {
      'created_at' => 'log_lines.created_at',
      'log_type' => 'log_lines.log_type',
      'source' => 'log_lines.source',
    }

    params[:sort_order] ||= 'ASC'

    @log_lines = filter_for LogLine, @fields
    @log_lines = LogLine.order(:created_at).paginate(page: params[:page])
  end

  def root
  end
end
