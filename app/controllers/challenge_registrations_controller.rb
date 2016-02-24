class ChallengeRegistrationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_challenge, only: [:create]
  before_filter :load_and_authorize_registration, only: [:destroy]

  def create
    @registration = @challenge.registrations.new
    @registration.user_id = current_user.id

    if @registration.save
      session[:share_modal] = 'new_registration_challenge_share_prompt'
      session[:share_modal_model] = 'challenge'
      session[:share_modal_model_id] = @challenge.id
      session[:share_modal_time] = 'after_redirect'

      # flash[:notice] = "Welcome to #{@challenge.name}!"
    else
      flash[:alert] = "Something wrong happened, please try again."
    end
    redirect_to @challenge
  end

  def destroy
    @registration.destroy
    redirect_to @challenge, notice: "You've left #{@challenge.name}. Feel free to register again at any time."
  end

  private
    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
    end

    def load_and_authorize_registration
      @challenge = Challenge.find params[:challenge_id]
      @registration = @challenge.registrations.where(user_id: current_user.id).first!
      authorize! self.action_name.to_sym, @registration
    end
end