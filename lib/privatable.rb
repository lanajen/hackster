module Privatable
  module InstanceMethods
    def public?
      private == false
    end

    def visible_to? user
      project = respond_to?(:project) ? self.project : self
      public? or user.has_access_group_permissions? self or user.is_team_member? project
    end
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :attr_accessible, :private, :privacy_rules_attributes
    base.send :has_many, :privacy_rules, as: :privatable, dependent: :destroy
    base.send :accepts_nested_attributes_for, :privacy_rules, allow_destroy: true
  end
end