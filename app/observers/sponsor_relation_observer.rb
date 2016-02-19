class SponsorRelationObserver < ActiveRecord::Observer
  def after_create record
    Cashier.expire "challenge-#{record.challenge_id}-sponsors"
    record.challenge.purge
  end

  alias_method :after_destroy, :after_create
end