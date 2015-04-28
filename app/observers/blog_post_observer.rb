class BlogPostObserver < ActiveRecord::Observer
  def after_update record
    record.purge and record.purge_all if record.public  # public != public?
  end

  def after_destroy record
    record.purge and record.purge_all if record.public?
  end
end