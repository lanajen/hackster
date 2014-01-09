class TeamObserver < ActiveRecord::Observer
  def after_update record
    record.projects.each{ |p| p.update_slug! }
  end
end