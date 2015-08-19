module HstoreColumn
  module ClassMethods
    def hstore_column store_attribute, attribute, type, options={}
      attr_accessible attribute

      columns = hstore_columns.try(:dup) || {}
      columns[store_attribute] ||= []
      columns[store_attribute] += [attribute] unless attribute.in? columns[store_attribute]
      self.hstore_columns = columns

      self.send :define_method, "#{attribute}" do
        inst_var = instance_variable_get("@#{attribute}")
        return inst_var unless inst_var.nil?

        column_name = options[:column_name].presence || attribute
        value = send(store_attribute).try(:[], column_name.to_s)

        value = if value.nil? and options[:default]
          send "default_#{attribute}"
        else
          cast_value value, type
        end

        instance_variable_set("@#{attribute}", value)
      end

      self.send :define_method, "#{attribute}=" do |val|
        current_val = send(attribute)
        return val if val == current_val

        store = send(store_attribute).try(:dup) || {}

        cast_val = cast_value val, type
        unless instance_variable_get("@#{attribute}_was_set")
          instance_variable_set "@#{attribute}_was", current_val
          instance_variable_set "@#{attribute}_was_set", true
        end
        unless cast_val.nil?
          instance_variable_set "@#{attribute}", cast_val
        else
          remove_instance_variable "@#{attribute}"
        end
        attribute_will_change! attribute

        val = case type
        when :array
          val.join(',')
        when :boolean
          val.to_i
        when :datetime
          val.to_datetime.to_i
        when :json_object
          val.to_s
        else
          val
        end if val
        column_name = options[:column_name].presence || attribute
        store[column_name] = val

        self.send "#{store_attribute}=", store
        cast_val
      end

      self.send :define_method, "#{attribute}_was" do
        return instance_variable_get("@#{attribute}_was") if instance_variable_get("@#{attribute}_was_set")

        instance_variable_set "@#{attribute}_was_set", true
        instance_variable_set "@#{attribute}_was", send(attribute)
      end

      self.send :define_method, "#{attribute}_changed?" do
        send(attribute) != send("#{attribute}_was")
      end

      if options[:default]
        self.send :define_method, "default_#{attribute}" do
          case options[:default]
          when Proc
            options[:default].call(self)
          when String
            options[:default].gsub(/%\{([^\}]+)\}/) do
              eval $1
            end
          else
            options[:default]
          end
        end
      end

      if type == :boolean
        self.send :define_method, "#{attribute}?" do
          send attribute
        end
      end
    end
  end

  module InstanceMethods
    private
      def cast_value value, type
        case type
        when :array
          value.split(',').flatten
        when :boolean
          value == '1' or value == true or value == 'true' or value == 't' or value == 1
        when :datetime
          value ? Time.at(value.to_i) : nil
        when :float
          value ? value.to_f : nil
        when :integer
          value ? value.to_i : nil
        when :json_object
          value.present? ? JSON.parse(value) : nil
        when :string
          value
        else
          value
        end unless value.nil?
      end

      def h
        ClassHelper.new
      end

      def hstore_reset_was_attributes
        hstore_columns.each do |store_attribute, attributes|
          attributes.each do |attribute|
            instance_variable_set "@#{attribute}_was_set", false
            instance_variable_set "@#{attribute}_was", nil
          end
        end
      end
  end

  def self.included base
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :class_attribute, :hstore_columns, instance_writer: false
    base.send :after_commit, :hstore_reset_was_attributes
  end
end