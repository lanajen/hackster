class Spark::AuthorizationsController < MainBaseController
  force_ssl if: :ssl_configured?
  before_filter :authenticate_user!

  def index
    @token = current_user.authorizations.where(provider: 'Spark').first.try(:token)
  end

  def show
    auth = current_user.authorizations.where(provider: 'Spark').first!

    render json: { token: auth.token }
  end

  def new
    if current_user.authorizations.where(provider: 'Spark').first
      redirect_to spark_authorizations_path and return
    end
  end

  def create
    auth = current_user.authorizations.new(provider: 'Spark', token: params[:token],
      uid: 'none')

    if auth.save
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, nothing: true
    end
  end

  def destroy
    token = params[:token]

    redirect_to spark_authorizations_path, alert: "Could not find token." and return unless token

    current_user.authorizations.where(provider: 'Spark', token: token).destroy_all

    redirect_to spark_authorizations_path, notice: "Token deleted."
  end
end