module EditableSlug
  module ClassMethods
    def editable_slug attribute_name
      attr_accessible :"new_#{attribute_name}"
      attr_writer :"new_#{attribute_name}", :"new_#{attribute_name}_changed"
      after_validation :"assign_new_#{attribute_name}"

      self.send :define_method, "new_#{attribute_name}" do
        eval "
          @new_#{attribute_name} ||= #{attribute_name}
        "
      end

      self.send :define_method, "assign_new_#{attribute_name}" do
        instance_variable_set "@old_#{attribute_name}", send(attribute_name)
        self.send "new_#{attribute_name}_changed=", (send(attribute_name) != send("new_#{attribute_name}"))
        self.send "#{attribute_name}=", send("new_#{attribute_name}")
      end

      self.send :define_method, "new_#{attribute_name}_changed?" do
        instance_variable_get "@new_#{attribute_name}_changed"
      end

      self.send :define_method, "#{attribute_name}=" do |val|
        super(val)
        self.send "new_#{attribute_name}=", val
      end
    end
  end

  module InstanceMethods
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end