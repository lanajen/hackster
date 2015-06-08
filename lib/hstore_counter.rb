module HstoreCounter
  module ClassMethods
    def counters_column store_attribute, options={}
      @@counters_column = store_attribute
      @@counters_options = options

      if column_for_attribute(store_attribute).type == :text
        store store_attribute, accessors: []
      end
    end

    def has_counter counter, count_method
      hstore_column @@counters_column, "#{counter}_count", :integer, default: 0, column_name: (@@counters_options[:long_format] ? nil : counter)

      columns = counter_columns.try(:dup) || {}
      columns[counter] = count_method
      self.counter_columns = columns

      send :define_singleton_method, "most_#{counter}" do
        order "CAST(groups.hcounters_cache -> '#{counter}' AS INTEGER) DESC"
      end
    end
  end

  module InstanceMethods
    def filter_counters counters, options={}
      counters.reject!{ |k,v| k.in? options[:except] } if options[:except]
      counters.select!{ |k,v| k.in? options[:only] } if options[:only]
      counters
    end

    def reset_counters options={}
      options[:reset] = true
      update_counters options
    end

    def update_counters options={}
      filter_counters(counter_columns.keys, options).each do |counter|
        value = options[:reset] ? 0 : eval(counter_columns[counter])
        send "#{counter}_count=", value
      end
      save unless options[:assign_only]
    end
  end

  def self.included base
    # dependency
    base.send :include, HstoreColumn unless base.included_modules.include? HstoreColumn

    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :class_attribute, :counter_columns, instance_writer: false
  end
end