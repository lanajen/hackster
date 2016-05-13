class Users::Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  layout 'doorkeeper/admin'

  before_filter :authenticate_user!
  before_filter :set_application, only: [:show, :edit, :update, :destroy]

  def index
    @applications = current_user.oauth_applications
  end

  def new
    @application = Doorkeeper::Application.new
  end

  def create
    @application = current_user.oauth_applications.new(application_params)

    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  def update
    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to oauth_application_url(@application)
    else
      render :edit
    end
  end

  def destroy
    flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :destroy]) if @application.destroy
    redirect_to oauth_applications_url
  end

  private

  def set_application
    @application = Doorkeeper::Application.find(params[:id])
    authorize! :manage, @application
  end

  def application_params
    if params.respond_to?(:permit)
      params.require(:doorkeeper_application).permit(:name, :redirect_uri, :scopes)
    else
      params[:doorkeeper_application].slice(:name, :redirect_uri, :scopes) rescue nil
    end
  end
end