module Chores
  class PruneImpressionsWorker
    include Sidekiq::Worker

    def perform
      Impression.where(controller_name: 'projects', impressionable_type: 'BaseArticle').delete_all
    end
  end
end