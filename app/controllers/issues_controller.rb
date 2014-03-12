class IssuesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]
  before_filter :load_project
  before_filter :load_issue, only: [:show, :edit, :update, :destroy, :update_workflow]
  before_filter :set_project_mode
  layout 'project'

  def index
    authorize! :read, Issue, @project
    title "Issues for #{@project.name}"
    @issues = @project.issues.order(created_at: :desc).where(type: 'Issue')
    params[:status] ||= 'open'
    @issues = @issues.where(workflow_state: params[:status]) if params[:status].in? %w(open closed)
  end

  def show
    authorize! :read, @issue
    title "Issues > #{@issue.title} | #{@project.name}"
  end

  def new
    authorize! :create, Issue, @project
    title "New issue | #{@project.name}"
    @issue = @project.issues.new
  end

  def create
    @issue = @project.issues.new(params[:issue])
    authorize! :create, @issue
    @issue.user = current_user

    if @issue.save
      redirect_to project_issue_path(@project.user_name_for_url, @project.slug, @issue.sub_id), notice: 'Issue created.'
    else
      render 'new'
    end
  end

  def edit
    authorize! :edit, @issue
    title "Issues > Edit #{@issue.title} | #{@project.name}"
  end

  def update
    authorize! :edit, @issue
    if @issue.update_attributes(params[:issue])
      redirect_to project_issue_path(@project.user_name_for_url, @project.slug, @issue.sub_id), notice: 'Issue updated.'
    else
      render 'edit'
    end
  end

  def update_workflow
    authorize! :edit, @issue
    if params[:event].in? %w(reopen close)
      begin
        @issue.send "#{params[:event]}!"
        comment = @issue.comments.new
        comment.user = current_user
        action = case params[:event]
        when 'reopen'
          'reopened'
        when 'close'
          'closed'
        end
        comment.body = "<p>Issue #{action}.</p>"
        comment.save
      rescue Workflow::NoTransitionAllowed
      end
    end

    redirect_to user_return_to, notice: "Update successful!"
  end

  def destroy
    authorize! :destroy, @issue
    @issue.destroy

    redirect_to user_return_to, notice: 'Issue destroyed'
  end

  private
    def load_issue
      @issue = @project.issues.where(sub_id: params[:id]).first!
    end
end