class IndexerQueue < BaseWorker
  sidekiq_options queue: :default

  def store model, id
    model.constantize.index.store model.constantize.find(id)
  end

  def remove model, id
    model.constantize.index.remove model.constantize.find(id)
  end
end