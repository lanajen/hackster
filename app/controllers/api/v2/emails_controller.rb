class Api::V2::EmailsController < Api::V2::BaseController
  def create
    email_user_name = params[:recipient].split(/@/)[0].split(/\+/)
    user_hid = email_user_name[0]
    comment_hid = email_user_name[1]
    body = params[:'stripped-text']

    if is_webhook_valid? and user_hid.present? and comment_hid.present? and body.present?
      IncomingEmailWorker.perform_async 'process', user_hid, comment_hid, body
      render status: :ok, nothing: true
    else
      render status: :not_acceptable, nothing: true
    end
  end

  private
    def is_webhook_valid?
      data = [params[:timestamp], params[:token]].join('')
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['MAILGUN_API_KEY'], data)
      signature == params[:signature]
    end
end