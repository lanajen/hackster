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

    def load_all before_date=nil, after_id=nil
      impressions = Impression.where(impressionable_type: 'BaseArticle').where.not(controller_name: 'projects')
      impressions = impressions.where("impressions.created_at < ?", before_date) if before_date
      impressions = impressions.where("impressions.id > ?", after_id) if after_id
      impressions.find_each do |impression|
        @id = impression.id
        # doesn't put everything in the queue at once so as to not overload the DB (hopefully)
        # should take about a day altogether
        Chores::ProjectImpressionMoveWorker.perform_in 0.05.seconds, 'create_single_impression', impression.id
      end
    rescue => e
      raise "failed on ID #{@id} because #{e.inspect}"
    end

    def create_single_impression id
      impression = Impression.find id
      impression_attributes = impression.attributes.slice(*COLUMNS)
      impression_attributes[:project_id] = impression.impressionable_id
      ProjectImpression.create!(impression_attributes)
    end
  end
end
