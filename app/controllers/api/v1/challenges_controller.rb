class Api::V1::ChallengesController < Api::V1::BaseController
  def index
    challenges = Challenge.visible.publyc

    if params[:state].try(:to_sym).in?(Challenge.workflow_spec.states.keys)
      challenges = challenges.where workflow_state: params[:state]
    end

    challenges = challenges.ends_last.paginate(page: safe_page_params)

    render json: ChallengeCollectionJsonDecorator.new(challenges).node.to_json
  end
end