module Counter
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
    base.send :include, InstanceMethods
  end
end