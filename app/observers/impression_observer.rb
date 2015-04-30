class ImpressionObserver < ActiveRecord::Observer
  def after_create record
    if record.impressionable_type == 'Project'
      project = record.impressionable

      if project.impressions_count % 999 == 0  # every 1000 views. This executes before impressions_count is updated, which means that the counter is about to become 1000
        # memcache
        keys = ["project-#{project.id}-thumb", "project-#{project.id}-teaser", "project-#{project.id}"]
        project.users.each { |u| keys << "user-#{u.id}" }
        Cashier.expire *keys

        # fastly
        project.users.each { |u| u.purge }
        project.purge
      end
    end
  end
end