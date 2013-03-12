module Youtube
  class Video < Youtube::Base
    def self.info video_id
      get("/videos/#{video_id}?v=2").parsed_response
    end
  end
end
