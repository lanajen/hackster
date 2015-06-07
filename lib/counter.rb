module Counter
  # module ClassMethods
  #   def has_counter store_attribute, counter, count_method
  #     attr_accessible attribute
  #     store_accessor store_attribute, counter

  #     columns = counter_columns.try(:dup) || {}
  #     columns[store_attribute] ||= []
  #     columns[store_attribute] += [attribute]
  #     self.counter_columns = columns


  #   end
  # end

  module InstanceMethods
    def filter_counters counters, options={}
      counters.reject!{ |k,v| k.in? options[:except] } if options[:except]
      counters.select!{ |k,v| k.in? options[:only] } if options[:only]

      use_counters = {}
      counters.each do |counter, method|
        use_counters[:"#{counter}_count"] = (options[:reset] ? 0 : eval(method))
      end
      use_counters
    end

    def reset_counters options={}
      options[:reset] = true
      update_counters options
    end

    def update_counters options={}
      # respond_to?(:counter_columns) ? counter_columns : counters
      do_update_counters filter_counters(counters, options), options
    end

    private
      def do_update_counters counters, options={}
        if options[:solo_counters]
          update_attributes counters, without_protection: true
        else
          counters.each do |counter, method|
            attribute_will_change! counter
          end
          assign_attributes counters, without_protection: true  # assign to update counters_cache

          unless options[:assign_only]
            update_attributes({ counters_cache: counters_cache }, without_protection: true)
          end
        end
      end
  end

  def self.included base
    # base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    # base.send :class_attribute, :counter_columns, instance_writer: false
  end
end