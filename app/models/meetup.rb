# require 'ruby_meetup'

class Meetup
  def client
    return @client if @client
    RubyMeetup::ApiKeyClient.key = MEETUP_API_KEY
    @client = RubyMeetup::ApiKeyClient.new
  end

  def get_next_meetup group_url
    response = client.get_path '/2/events', { group_urlname: group_url }
    results = response['results']
    next_event = results.first
    # time
    # event_url
    # name
  end
end