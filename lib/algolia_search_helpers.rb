require 'algoliasearch'

module AlgoliaSearchHelpers
  module ClassMethods
    def algolia_batch_import records, limit
      records.order(:id).limit(limit).each_slice(1_000) do |batch|
        algolia_index.add_objects batch.map(&:to_indexed_json)
      end
    end

    def algolia_index
      @algolia_index ||= Algolia::Index.new(algolia_index_name)
    end

    def algolia_index_name
      "#{ALGOLIA_INDEX_PREFIX}_#{self.model_name.name.underscore}"
    end

    def has_algolia_index no_index_condition
      after_commit on: [:create, :update] do
        if eval(no_index_condition)
          IndexerQueue.perform_async :remove, self.model_name.name, self.id
        else
          IndexerQueue.perform_async :store, self.model_name.name, self.id
        end
      end
      after_destroy do
        # tricky to move to background; by the time it's processed the model might not exist
        algolia_index.delete_object algolia_id
      end
    end
  end

  module InstanceMethods
    def algolia_id
      "#{self.class.model_name.name.underscore}_#{id}"
    end

    def algolia_index
      self.class.algolia_index
    end
  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end