class Api::Private::ChallengeRegistrationsController < Api::Private::BaseController
  before_filter :authenticate_user!

  def update
    registration = ChallengeRegistration.where(challenge_id: params[:challenge_id], user_id: current_user.id).first!

    if registration.update_attributes(params[:challenge_registration])
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: { errors: registration.errors }
    end
  end
end