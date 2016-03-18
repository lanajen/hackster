class ProjectCounterAccessor
  def initialize store, platform_id
    @store = store || {}
    @platform_id = platform_id
  end

  def get
    @store[@platform_id] || 0
  end

  def set val
    @store[@platform_id] = val
  end

  def store
    @store
  end
end