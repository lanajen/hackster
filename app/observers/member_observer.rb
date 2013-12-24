class MemberObserver < ActiveRecord::Observer
  def after_save record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.user.update_counters only: [:projects, :live_projects]

      record.group.projects.each{ |p| p.update_slug! } if record.group and record.group.is? :team
    end
end