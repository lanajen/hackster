class TagObserver < ActiveRecord::Observer
  def after_create record
    if record.type == 'PlatformTag' and record.taggable_type == 'Project'
      project = record.taggable
      project.platform_tags_string_from_tags
      project.save
    end
  end
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