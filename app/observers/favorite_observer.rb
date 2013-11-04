class FavoriteObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.project.update_counters only: [:respects]
      record.user.update_counters only: [:respects]
    end
end