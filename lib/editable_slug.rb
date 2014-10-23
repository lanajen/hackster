module EditableSlug
  module ClassMethods
    def editable_slug attribute_name
      attr_accessible :"new_#{attribute_name}"
      attr_writer :"new_#{attribute_name}"
      before_save :"assign_new_#{attribute_name}"

      self.send :define_method, "new_#{attribute_name}" do
        eval "
          @new_#{attribute_name} ||= #{attribute_name}
        "
      end

      self.send :define_method, "assign_new_#{attribute_name}" do
        instance_variable_set "@old_#{attribute_name}", send(attribute_name)
        self.send "#{attribute_name}=", send("new_#{attribute_name}")
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