class IndexerQueue < BaseWorker
  sidekiq_options queue: :default, retry: false, unique: :all

  def store model_class, id
    model = model_class.constantize.find(id)
    model.algolia_index.save_object model.to_indexed_json, model.algolia_id
  end

  def remove model_class, id
    model = model_class.constantize.find(id)
    model.algolia_index.delete_object model.algolia_id
  end
end