class BlogPostObserver < ActiveRecord::Observer
  def after_update record
    record.purge and record.purge_all if record.publyc  # public != public?
  end

  def after_destroy record
    record.purge and record.purge_all if record.publyc?
  end
end