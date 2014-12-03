class TwitterQueue < BaseWorker
  sidekiq_options queue: :default, retry: 0

  def update message
    begin
      twitter_client.update(message)
    rescue => e
      LogLine.create(log_type: 'error', source: 'twitter', message: "Error: #{e.inspect} // Tweet: \"#{message}\"")
    end
  end

  private
    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = TWITTER_CONSUMER_KEY
        config.consumer_secret     = TWITTER_CONSUMER_SECRET
        config.access_token        = TWITTER_ACCESS_TOKEN
        config.access_token_secret = TWITTER_ACCESS_SECRET
      end
    end
end