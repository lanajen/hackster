module HasAbility
  module InstanceMethods
    def ability
      @ability ||= Ability.new(self)
    end
  end

  def self.included base
    base.include InstanceMethods
    base.send :delegate, :can?, :cannot?, to: :ability
  end
end