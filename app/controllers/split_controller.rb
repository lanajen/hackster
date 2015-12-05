class SplitController < ApplicationController
  def start_ab_test
    experiment = params[:experiment]
    control = params[:control]
    alternatives = params[:alternatives]
    alternative = (control and alternatives) ? ab_test(experiment, control, *alternatives) : ab_test(experiment)
    render json: { alternative: alternative }
  rescue Split::ExperimentNotFound
    render status: :unprocessable_entity, nothing: true
  end

  def finished_test
    experiment = params[:experiment]
    finished(experiment)
    render status: :ok, nothing: true
  end

  def finish_and_redirect
    experiment = params[:experiment]
    goal = params[:goal]
    finished goal.present? ? { :"#{experiment}" => goal } : experiment
    redirect_to params[:redirect_to] || get_redirect_url_for(experiment)
  end

  def validate_step
    experiment = params[:experiment]
    redirect_to get_redirect_url_for(experiment) || root_path
  end

  private
    def get_redirect_url_for experiment
      redirects = {
        'signup_button_global' => new_user_registration_path(experiment: experiment),
      }
      redirects[experiment]
    end
end