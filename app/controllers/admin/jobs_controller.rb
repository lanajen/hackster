class Admin::JobsController < Admin::BaseController
  def index
    title "Admin / Jobs - #{safe_page_params}"
    @fields = {
      'created_at' => 'jobs.created_at',
      'state' => 'jobs.workflow_state',
      'title' => 'jobs.title',
      'employer_name' => 'jobs.employer_name',
    }

    params[:sort_by] ||= 'created_at'

    @jobs = filter_for Job, @fields
  end

  def new
    @job = Job.new(params[:job])
  end

  def create
    @job = Job.new(params[:job])

    if @job.save
      redirect_to admin_jobs_path, :notice => 'New job created'
    else
      render :new
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])

    if @job.update_attributes(params[:job])
      redirect_to admin_jobs_path, :notice => 'Job successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to admin_jobs_path, :notice => 'Job successfuly deleted'
  end
end