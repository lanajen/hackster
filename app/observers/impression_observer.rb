class ImpressionObserver < ActiveRecord::Observer
  def after_create record
    if record.impressionable_type == 'Project'
      project = record.impressionable

      if project.impressions_count % 249 == 0  # every 250 views. This executes before impressions_count is updated, which means that the counter is about to become 250
        # memcache
        keys = ["project-#{project.id}-thumb", "project-#{project.id}-teaser", "project-#{project.id}-left-column", "project-#{project.id}"]
        project.users.each { |u| keys << "user-#{u.id}" }
        Cashier.expire *keys

        # fastly
        project.users.each { |u| u.purge }
        project.purge
      end
    end
  end
end