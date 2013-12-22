module Privatable
  module ClassMethods
    def private
      where private: true
    end
  end

  module InstanceMethods
    def private?
      private == true
    end

    def public?
      private == false
    end

    def visible_to? user
      project = respond_to?(:project) ? self.project : self
      public? or user.is_team_member? project
    end
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :attr_accessible, :private#, :privacy_rules_attributes
    # base.send :has_many, :privacy_rules, as: :privatable, dependent: :destroy
    # base.send :accepts_nested_attributes_for, :privacy_rules, allow_destroy: true
  end
end