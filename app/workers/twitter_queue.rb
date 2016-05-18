class TwitterQueue < BaseWorker
  INTERVAL_BETWEEN_UPDATES = 15
  sidekiq_options queue: :default, retry: 0

  def post_project_tweet id
    project = BaseArticle.find_by_id id
    project.post_tweet!
  end

  def throttle_project_tweet id
    if Time.now > next_update
      post_project_tweet id
    else
      self.class.perform_at next_update, 'post_project_tweet', id
      set_next_update
    end
  end

  private
    def last_update
      return @last_update if @last_update

      if value = redis.get('last_update')
        @last_update = Time.at value.to_i
      end
    end

    def next_update
      if last_update and (last_update + INTERVAL_BETWEEN_UPDATES * 60) > Time.now
        last_update + INTERVAL_BETWEEN_UPDATES * 60
      else
        Time.now
      end
    end

    def set_next_update
      redis.set 'last_update', next_update.to_i
    end

    def redis
      @redis ||= Redis::Namespace.new('twitter_queue', redis: RedisConn.conn)
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = TWITTER_CONSUMER_KEY
        config.consumer_secret     = TWITTER_CONSUMER_SECRET
        config.access_token        = TWITTER_ACCESS_TOKEN
        config.access_token_secret = TWITTER_ACCESS_SECRET
      end
    end
end