class ChallengeRegistrationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_challenge, only: [:create]
  before_filter :load_and_authorize_registration, only: [:destroy]

  def create
    @registration = @challenge.registrations.new
    @registration.user_id = current_user.id

    if @registration.save
      flash[:notice] = "Welcome to #{@challenge.name}!"
    else
      flash[:alert] = "Something wrong happened, please try again."
    end
    redirect_to @challenge
  end

  def destroy
    @registration.destroy
    redirect_to @challenge, notice: "You've quit #{@challenge.name}. Feel free to register again at any time."
  end

  private
    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
    end

    def load_and_authorize_registration
      @registration = ChallengeRegistration.find params[:id]
      raise ActiveRecord::RecordNotFound unless params[:challenge_id] == @registration.challenge_id.to_s
      authorize! self.action_name.to_sym, @registration
      @challenge = @registration.challenge
    end
end