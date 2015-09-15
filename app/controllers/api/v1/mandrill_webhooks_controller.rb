class Api::V1::MandrillWebhooksController < Api::V1::BaseController
  def unsub
    events = JSON.parse params[:mandrill_events]
    emails = events.map do |event|
      event['msg']['email']
    end
    User.where(email: emails).each do |user|
      user.set_subscriptions_for 'email', []
    end
    render status: :ok, nothing: true
  end
end