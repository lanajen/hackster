class BlogPostObserver < ActiveRecord::Observer
  def after_update record
    FastlyWorker.perform_async 'purge', record.record_key, record.table_key if record.publyc  # public != public?
  end

  def after_destroy record
    FastlyWorker.perform_async 'purge', record.record_key, record.table_key if record.publyc?
  end
end