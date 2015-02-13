require "net/http"
require "uri"

ZAPIER_WEBHOOK_URL = 'https://zapier.com/hooks/catch/o01ja3/'

class ZapierQueue < BaseWorker

  def post email

    uri = URI.parse(ZAPIER_WEBHOOK_URL)

    data = {
      'email' => email,
    }.to_json

    response = Net::HTTP.post_form(uri, payload: data)
  end
end