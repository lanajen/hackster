class ProjectCounter
  def initialize user
    @user = user
  end

  def count platform
    platform ? ProjectCounterAccessor.new(get_store, platform.id).get : @user.live_projects_count
  end

  def counts
    get_store
  end

  def update platform
    projects = @user.projects.publyc.own.with_group(platform, all_moderation_states: true)
    accessor = ProjectCounterAccessor.new(get_store, platform.id)
    accessor.set(projects.count)
    set_store accessor.store
  end

  def update_all
    Platform.joins(:client_subdomain).each do |platform|
      update platform
    end
    @user.save
  end

  private
    def get_store
      eval @user.projects_counter_cache
    end

    def set_store val
      @user.projects_counter_cache = val.to_s
    end
end