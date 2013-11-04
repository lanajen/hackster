class TagObserver < ActiveRecord::Observer
  # def after_create record
  #   update_counters record
  # end

  # def after_destroy record
  #   update_counters record
  # end

  # private
  #   def update_counters record
  #     record.taggable.update_counters only: [:"#{record.type.underscore}s"]
  #   end
end