module Roles
  module ClassMethods

    def set_roles attribute, roles
      class_variable_set "@@#{attribute}", roles

      (class << self; self; end).instance_eval do
        define_method "#{attribute}" do
          class_variable_get "@@#{attribute}"
        end
        define_method "with_#{attribute}" do |_roles|
          bits = send("bits_for_#{attribute}_query", _roles)
          conditions = bits.map{|b| "(#{self.table_name}.#{attribute}_mask & #{b} > 0)" }
          eval "
            where('#{conditions.join(' OR ')}')
          "
        end
        define_method "without_#{attribute}" do |_roles|
          bits = send("bits_for_#{attribute}_query", _roles)
          conditions = bits.map{|b| "(#{self.table_name}.#{attribute}_mask & #{b} = 0)" }
          eval "
            where('#{conditions.join(' AND ')} OR #{attribute}_mask IS NULL')
          "
        end
        define_method "bits_for_#{attribute}_query" do |_roles|
          _roles = [_roles] unless _roles.class == Array
          bits = _roles.map{|r| eval("2**#{attribute}.index(r.to_s)") }
        end
      end

      attr_accessible :"#{attribute}"

      self.send :define_method, "#{attribute}=" do |roles|
        roles = [roles] unless roles.class == Array
        eval "
          self.#{attribute}_mask = (roles & self.class.#{attribute}).map { |r| 2**self.class.#{attribute}.index(r) }.sum
        "
      end
      self.send :define_method, "#{attribute}" do
        eval "
          self.class.#{attribute}.reject { |r| ((#{attribute}_mask || 0) & 2**self.class.#{attribute}.index(r)).zero? }
        "
      end
      self.send :define_method, "#{attribute}_symbols" do
        eval "
          #{attribute}.map(&:to_sym)
        "
      end
    end
  end

  def self.included base
    base.send :extend, ClassMethods
  end
end