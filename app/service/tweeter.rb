class Tweeter
  attr_accessor :message

  def initialize message
    @message = message
  end

  def update
    begin
      ENV['ENABLE_TWEETS'] == 'true' ? twitter_client.update(message) : puts("Twitter message: #{message}")
    rescue => e
      LogLine.create(log_type: 'error', source: 'twitter', message: "Error: #{e.inspect} // Tweet: \"#{message}\"")
    end
  end

  def update_with_media media_url
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
    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = TWITTER_CONSUMER_KEY
        config.consumer_secret     = TWITTER_CONSUMER_SECRET
        config.access_token        = TWITTER_ACCESS_TOKEN
        config.access_token_secret = TWITTER_ACCESS_SECRET
      end
    end
end