class TwitterQueue < BaseWorker
  INTERVAL_BETWEEN_UPDATES = 15
  sidekiq_options queue: :default, retry: 0

  def schedule_project_tweet id, at=nil
    project = BaseArticle.find_by_id id

    if at
      project.post_new_tweet_at! DateTime.parse(at)
    else
      project.post_new_tweet!
    end
  end

  def throttle_update message
    if Time.now > next_update
      update message
    else
      self.class.perform_at next_update, 'update', message
      set_next_update
    end
  end

  def update message
    begin
      ENV['ENABLE_TWEETS'] == 'true' ? twitter_client.update(message) : puts("Twitter message: #{message}")
    rescue => e
      LogLine.create(log_type: 'error', source: 'twitter', message: "Error: #{e.inspect} // Tweet: \"#{message}\"")
    end
  end

  def update_with_media message, media_url
    LogLine.create(log_type: 'error', source: 'twitter', message: "Invalid arguments: media_url is empty") and return if media_url.blank?

    begin
      content = open(media_url).read
      full_file_name = File.basename media_url
      file_name = full_file_name.split(/\./)[0]
      extension = full_file_name.split(/\./)[-1]

      file = Tempfile.new([file_name, ".#{extension}"], nil, encoding: 'ascii-8bit')
      file.write content
      file.rewind
      ENV['ENABLE_TWEETS'] == 'true' ? twitter_client.update_with_media(message, file) : puts("Twitter message: #{message} (media: #{media_url})")

    # rescue => e
    #   LogLine.create(log_type: 'error', source: 'twitter', message: "Error: #{e.inspect} // Tweet: \"#{message}\"")
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