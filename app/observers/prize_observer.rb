class PrizeObserver < ActiveRecord::Observer
  def after_update record
    if (record.changed? & %w(name cash_value description quantity link position)).any?
      expire_cache record
    end
  end

  def after_create record
    expire_cache record
  end

  alias_method :after_destroy, :after_create

  private
    def expire_cache record
      Cashier.expire "challenge-#{record.challenge_id}-prizes"
      record.challenge.purge
    end
end