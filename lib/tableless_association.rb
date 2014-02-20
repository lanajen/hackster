module TablelessAssociation
  module ClassMethods
    def has_many_tableless association_name, opts={}
      if opts[:order]
        has_many :"#{association_name}", -> { order(opts[:order]) }
      else
        has_many :"#{association_name}"
      end
      attr_accessible :"#{association_name}_attributes"
      accepts_nested_attributes_for :"#{association_name}"
      before_validation :"validate_#{association_name}"

      unless association_model = opts[:class_name]
        association_model = association_name.to_s.classify.constantize
        raise "Model name couldn't be inferred for #{association_name}. Please use 'has_many_tableless :<associations>, class_name: <ClassName>'." unless
          Object.const_defined? association_model.to_s
      end

      self.send :define_method, association_name do
        get_association association_name, association_model
      end
      self.send :define_method, "#{association_name}=" do |val|
        set_association association_name, association_model, val
      end
      self.send :define_method, "#{association_name}_attributes=" do |val|
        set_association_attributes association_name, val
      end
      self.send :define_method, "new_#{association_name.to_s.singularize}" do |val={}|
        new_association association_name, association_model, val
      end
      self.send :define_method, "validate_#{association_name}" do
        validate_association association_name
      end
    end
  end

  module InstanceMethods
    def get_association association_name, association_model
      association_instance = instance_variable_get "@#{association_name}"
      return association_instance if association_instance

      val = properties[:"#{association_name}"]

      association_instance = if val.present?
        YAML::load(val).map do |attrs|
          attrs.except!(:_destroy, '_destroy')
          association_model.new attrs.merge(widget_id: id)
        end
      else
        []
      end
      instance_variable_set "@#{association_name}", association_instance
    end

    def new_association association_name, association_model, attrs={}
      records = send("#{association_name}")

      records << association_model.new(attrs.merge(widget_id: id))

      _set_association association_name, records
    end

    def set_association association_name, association_model, val
      raise 'type not supported' unless val.kind_of? Array

      records = normalize_records val, association_model

      _set_association association_name, records
    end

    def set_association_attributes association_name, val
      self.send "#{association_name}=", val.delete_if{ |i, attrs| attrs['_destroy'] == '1' }.map{ |k,v| v }
    end

    def validate_association association_name
      records = send(association_name).map do |record|
        unless record.valid?
          record.errors.each do |attribute, message|
            attribute = "#{association_name}.#{attribute}"
            errors[attribute] << message
            errors[attribute].uniq!
          end
        end
        record
      end

      _set_association association_name, records
    end

    private
      def _set_association association_name, records
        instance_variable_set "@#{association_name}", records

        props = properties
        props[:"#{association_name}"] = YAML::dump(records.map(&:attributes))
        self.properties = props  # TODO: this attribute should be defined in the class
      end

      def normalize_records records, association_model
        records.map do |record|
          case record
          when Hash
            record
          when association_model
            record.attributes
          end
        end.map do |record|
          record.reject!{ |k,v| k == '_destroy' }
          association_model.new record
        end
      end
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end
