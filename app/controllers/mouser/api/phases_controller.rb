class Mouser::Api::PhasesController < Mouser::Api::BaseController
  def update
    if redis.get('active_phase').present?
      redis.set('active_phase', params[:id].to_s)
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, nothing: true
    end
  end
end