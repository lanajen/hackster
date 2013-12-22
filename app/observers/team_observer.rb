class TeamObserver < ActiveRecord::Observer
  def after_save record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.users.each{ |t| t.update_counters only: [:projects, :live_projects] }
    end
end