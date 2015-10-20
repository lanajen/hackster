class ProductObserver < ExternalProjectObserver
  def after_commit_on_create record
    ProjectWorker.perform_async 'update_platforms', record.id
  end
end