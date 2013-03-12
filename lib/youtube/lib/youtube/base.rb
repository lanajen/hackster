module Youtube
  class Base
    include HTTParty
    base_uri 'https://gdata.youtube.com/feeds/api'
  end
end
