class JobsController < MainBaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_action :current_site
  skip_before_action :current_platform
  skip_before_filter :set_view_paths
  skip_before_action :set_locale

  def index
    title 'Jobs for hardware developers'
    meta_desc "Are you a talented hardware developer with spare time? Find a job that's right for you."
    @jobs = Job.active.order(created_at: :desc)
  end

  def show
    if job = Job.find(params[:id])
      impressionist_async job, '', unique: [:session_hash]

      redirect_to job.url
    else
      redirect_to jobs_path, status: 302, alert: "This job doesn't exist."
    end
  end
end