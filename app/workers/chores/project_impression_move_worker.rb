module Chores
  class ProjectImpressionMoveWorker
    include Sidekiq::Worker

    COLUMNS = %w[
      user_id
      controller_name
      action_name
      view_name
      request_hash
      ip_address
      session_hash
      message
      referrer
      created_at
    ]

    def perform
      Impression.where(impressionable_type: 'BaseArticle', controller_name: 'projects').find_each do |impression|
        impression_attributes = impression.attributes.slice(*COLUMNS)
        Project.find(impression.impressionable_id).impressions.create!(impression_attributes)
      end
    end
  end
end
