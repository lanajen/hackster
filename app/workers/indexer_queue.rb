class IndexerQueue < BaseWorker
  sidekiq_options queue: :default

  def store model_class, id
    model = model_class.constantize.find_by_id(id)
    model_class.constantize.index.store model if model
  end

  def remove model, id
    model = model_class.constantize.find_by_id(id)
    model_class.constantize.index.remove model if model
  end
end