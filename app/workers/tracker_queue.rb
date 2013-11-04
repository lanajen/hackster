class TrackerQueue
  @queue = :trackers

  def self.perform env, method_name, *args
    Tracker.new({ env: env }).send method_name, *args
  end
end