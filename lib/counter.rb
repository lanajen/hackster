module Counter
  def filter_counters counters, options={}
    counters.reject!{ |k,v| k.in? options[:except] } if options[:except]
    counters.select!{ |k,v| k.in? options[:only] } if options[:only]

    use_counters = {}
    counters.each do |counter, method|
      use_counters[:"#{counter}_count"] = (options[:reset] ? 0 : eval(method))
    end
    puts use_counters.to_s
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
        assign_attributes counters, without_protection: true  # assign once to update counters_cache

        unless options[:assign_only]
          update_column :counters_cache, counters_cache.to_yaml
          assign_attributes YAML.load(counters_cache), without_protection: true  # assign twice so that it loses its YAML form
        end
      end
    end
end