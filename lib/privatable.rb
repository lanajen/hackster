module Privatable
  # we use pryvate and publyc so that as not to override the private and public
  # calls in ruby. same methods used on instances for consistency.
  # we keep the private instance method so we don't have to update the column names
  module ClassMethods
    def pryvate
      where private: true
    end

    def publyc
      where.not(private: true)
    end
  end

  module InstanceMethods
    def pryvate
      private
    end

    def pryvate=(val)
      self.private = val
    end

    def pryvate?
      private == true
    end

    def publyc?
      private == false
    end

    def publyc=(val)
      self.private = case val
      when String
        val.to_i.zero? ? true : false
      when TrueClass, FalseClass
        !val
      end
    end

    def publyc
      !private
    end

    def visible_to? user
      project = respond_to?(:project) ? self.project : self
      publyc? or user.is_team_member? project
    end
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :attr_accessible, :private, :publyc, :pryvate
  end
end