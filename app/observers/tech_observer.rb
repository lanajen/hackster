class TechObserver < ActiveRecord::Observer
  def after_save record
    return unless record.user_name.present?
    record.build_slug unless record.slug
    slug = record.slug
    slug.value = record.user_name
    slug.save
  end
end