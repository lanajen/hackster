class TeamObserver < ActiveRecord::Observer
  def after_update record
    record.projects.each do |p|
      SlugHistory.update_history_for p.id
      p.update_slug!
    end if record.user_name_changed?

    if record.full_name_changed?
      Cashier.expire "team-#{record.id}"
    end
  end
end