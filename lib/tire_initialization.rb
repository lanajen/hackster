require 'tire'

module TireInitialization
  module ClassMethods
    def has_tire_index no_index_condition, tire_index_name=ELASTIC_SEARCH_INDEX_NAME
      # include Tire::Model::Callbacks
      index_name tire_index_name

      after_commit on: [:create, :update] do
        if eval(no_index_condition)
          IndexerQueue.perform_async :remove, self.class.name, self.id
        else
          IndexerQueue.perform_async :store, self.class.name, self.id
        end
      end
      after_destroy do
        # tricky to move to background; by the time it's processed the model might not exist
        self.index.remove self
      end
    end
  end

  def self.included base
    base.send :include, Tire::Model::Search
    base.send :extend, ClassMethods
  end
end