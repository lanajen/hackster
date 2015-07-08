class StoreProductActionList
  def any?
    @actions.any?
  end

  def count
    @actions.count
  end

  def each &block
    @actions.each do |action|
      block.call(action)
    end
  end

  def initialize actions=[]
    @actions = actions.map do |action|
      StoreProductAction.new action
    end
  end

  def required_for? user
    return false unless any?

    @actions.each do |action|
      return true if action.completed_by?(user) == false
    end
    false
  end

  def to_s
    @actions.map do |action|
      action.to_s
    end.to_sentence
  end
end