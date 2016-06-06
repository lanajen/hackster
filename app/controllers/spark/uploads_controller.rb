class Spark::UploadsController < MainBaseController
  force_ssl if: :ssl_configured?
  before_filter :authenticate_user!
  before_filter :set_access_token

  def new
    redirect_to new_spark_authorization_path and return unless @token
  end

  private
    def set_access_token
      @token ||= current_user.authorizations.where(provider: 'Spark').first.try(:token)
    end
end