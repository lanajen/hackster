module Counter
  def filter_counters counters, options={}
    counters.reject!{ |k,v| k.in? options[:except] } if options[:except]
    counters.select!{ |k,v| k.in? options[:only] } if options[:only]

    use_counters = {}
    counters.each do |counter|
      use_counters[:"#{counter}_count"] = send(counter).send(:count)
    end
    use_counters
  end

  def update_counters options={}
    do_update_counters filter_counters(counters, options)
  end

  private
    def do_update_counters counters
      assign_attributes counters, without_protection: true  # assign once to update counters_cache
      update_column :counters_cache, counters_cache.to_yaml
      assign_attributes counters, without_protection: true  # assign twice so counters_cache loses it's yaml form
    end
end