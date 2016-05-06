class ChallengeJsonDecorator < BaseJsonDecorator
  def dates
    return @dates if @dates

    @dates = {}

    if model.activate_pre_registration?
      @dates[:pre_registration] = model.pre_registration_date if model.pre_registration_start_date
    end

    if model.activate_free_hardware?
      @dates[:free_hardware_end] = model.free_hardware_end_date if model.free_hardware_end_date
    end

    unless model.disable_projects_phase?
      @dates[:start] = model.start_date if model.start_date
      @dates[:end] = model.end_date if model.end_date
      @dates[:winners_announced] = model.winners_announced_date.strftime('%Y-%m-%dT00:00:00.000Z') if model.winners_announced_date
    end

    @dates
  end

  def node
    node = hash_for(%w(id name teaser))
    node[:url] = url.challenge_url(model)
    node[:dates] = dates
    node[:state] = model.workflow_state
    node[:free_hardware_available] = (model.activate_free_hardware? ? true : false)
    node
  end
end