module Chores
  class ProjectImpressionMoveWorker < BaseWorker
    sidekiq_options queue: :lowest, retry: 0

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

    def load_all start_after=nil
      impressions = Impression.where(impressionable_type: 'BaseArticle', controller_name: 'projects')
      impressions = impressions.where("impressions.id > ?", start_after) if start_after
      impressions.find_each do |impression|
        @id = impression.id
        # doesn't put everything in the queue at once so as to not overload the DB (hopefully)
        # should take about 2 days altogether
        Chores::ProjectImpressionMoveWorker.perform_in 0.08.seconds, 'create_single_impression', impression.id
      end
    rescue => e
      raise "failed on ID #{@id} because #{e.inspect}"
    end

    def create_single_impression id
      impression = Impression.find id
      impression_attributes = impression.attributes.slice(*COLUMNS)
      Project.find(impression.impressionable_id).impressions.create!(impression_attributes)
    end
  end
end
