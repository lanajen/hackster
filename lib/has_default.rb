module HasDefault
  module ClassMethods
    def has_default attribute_name, default, &block
      attr_accessible :"#{attribute_name}"
      store_accessor :properties, :"#{attribute_name}" unless block_given?

      send :define_method, "default_#{attribute_name}" do
        case default
        when String
          default.gsub(/%\{([a-z_\.\s\(\)]+)\}/) do
            eval $1
          end
        else
          default
        end
      end

      self.send :define_method, "#{attribute_name}" do
        if block_given?
          block.call(self).presence
        else
          self.properties[attribute_name].presence
        end || send("default_#{attribute_name}")
      end
    end
  end

  module InstanceMethods
    def h
      ClassHelper.new
    end
  end

  def self.included base
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end
end