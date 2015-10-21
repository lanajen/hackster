class ProjectCollectionObserver < ActiveRecord::Observer
  def after_create record
    update_project record.project if record.collectable_type == 'Assignment'
  end

  def after_destroy record
    update_counters record
    expire_cache record if record.workflow_state.in? ProjectCollection::VALID_STATES
  end

  def after_update record
    update_project record.project if record.collectable_id_changed? and record.collectable_type == 'Assignment'
    if record.workflow_state_changed?
      expire_cache record
      record.project.update_counters only: [:communities] if record.project_id and record.project
    end
  end

  def after_status_updated record, from=nil
    update_counters record unless record.collectable_type == 'Assignment'
    if record.workflow_state == 'approved' and from.to_s == 'pending_review' and record.collectable_type == 'Group'
      record.collectable.update_attribute :last_project_time, Time.now
    end
  end

  private
    def expire_cache record
      project = record.project
      return unless record.project

      # memcache
      keys = ["project-#{project.id}"]
      Cashier.expire *keys

      # fastly
      project.purge
      if record.collectable.class == Platform
        FastlyRails.purge_by_key "#{record.collectable.user_name}/home"
        record.collectable.purge
      end
    end

    def update_counters record
      return unless record.collectable.respond_to? :counters or record.collectable.respond_to? :counter_columns
      counters = [:projects]
      counters += [:external_projects, :private_projects] if record.collectable.class.in? [List, Platform]
      counters += [:products] if record.collectable.class.in? [Platform]
      record.collectable.update_counters only: counters
    end

    def update_project project
      Cashier.expire "project-#{project.id}-teaser"

      project.reject! if project.pending_review? and project.force_hide?
      # if project.issues.empty?
      #   issue = project.issues.new title: 'Feedback'
      #   issue.type = 'Feedback'
      #   issue.user_id = 0
      #   issue.save
      # end
    end
end