class ProjectCollectionObserver < ActiveRecord::Observer
  def after_create record
    expire_cache record unless record.collectable.class == Platform
  end

  def after_destroy record
    update_counters record
    expire_cache record if record.workflow_state.in? ProjectCollection::VALID_STATES
  end

  def after_update record
    if record.workflow_state_changed?
      record.project.update_counters only: [:communities] if record.project_id and record.project
      if record.certified_changed?
        expire_cache record, ["project-#{record.project_id}-certified"]
      else
        expire_cache record
      end
    elsif record.certified_changed?
      expire_cache record, ["project-#{record.project_id}-certified"]
    end

    if record.certified_changed? and record.certified?
      NotificationCenter.perform_in 1.hour, 'notify_all', :certified, 'project_collection', record.id
    end
  end

  def after_status_updated record, from=nil
    update_counters record unless record.collectable_type == 'Assignment'
    if record.workflow_state == 'approved' and from.to_s == 'pending_review' and record.collectable_type == 'Group'
      record.collectable.update_attribute :last_project_time, Time.now
    end
  end

  private
    def expire_cache record, extra_keys=[]
      project = record.project
      return unless record.project

      # memcache
      keys = extra_keys + ["project-#{project.id}-communities", "project-#{project.id}-teaser", "project-#{project.id}"]
      Cashier.expire *keys

      # fastly
      fastly_keys = []
      fastly_keys << project.record_key
      if record.collectable.class == Platform
        fastly_keys << "#{record.collectable.user_name}/home"
        fastly_keys << record.collectable.record_key
      end
      FastlyWorker.perform_async 'purge', *fastly_keys
    end

    def update_counters record
      return unless record.collectable.respond_to? :counters or record.collectable.respond_to? :counter_columns
      counters = [:projects]
      counters += [:external_projects, :private_projects] if record.collectable.class.in? [List, Platform]
      record.collectable.update_counters only: counters
    end
end