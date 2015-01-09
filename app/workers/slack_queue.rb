require "net/http"
require "uri"

class SlackQueue < BaseWorker
  sidekiq_options queue: :critical

  def post slack_hook_url, text, username, icon_url

    uri = URI.parse(slack_hook_url)

    data = {
      'text' => text,
      'username' => username,
      'icon_url' => icon_url,
    }.to_json

    response = Net::HTTP.post_form(uri, payload: data)
  end
end