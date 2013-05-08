class PrivacySettingsController < ApplicationController
  before_filter :load_and_authorize_record
  layout 'project', only: [:edit, :update]

  respond_to :html

  def edit
    @project = @record.respond_to?(:project) ? @record.project : @record
    @access_groups = @project.access_groups
  end

  def update
    if @record.update_attributes params[:record]
      flash[:notice] = "Privacy setting updated for #{@record.class.name} #{@record.name}"
    else
      flash[:alert] = "Privacy setting couldn't be updated for #{@record.class.name} #{@record.name}"
    end
    @project = @record.respond_to?(:project) ? @record.project : @record
    respond_with @project
  end

  def create
    update_privacy_to false
  end

  def destroy
    update_privacy_to true
  end

  private
    def load_and_authorize_record
      @record = params[:type].classify.constantize.find params[:id]
      authorize! :update, @record
    end

    def update_privacy_to boolean
      @record.private = boolean
      if @record.save
        flash[:notice] = "Privacy setting updated for #{@record.class.name} #{@record.name}"
      else
        flash[:alert] = "Privacy setting couldn't be updated for #{@record.class.name} #{@record.name}"
      end
      redirect_to params[:redirect_to]
    end
end