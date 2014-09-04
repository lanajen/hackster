class TeamObserver < ActiveRecord::Observer
  def after_update record
    record.projects.each{ |p| p.update_slug! }

    if record.full_name_changed?
      Cashier.expire "team-#{record.id}"
    end
  end
end