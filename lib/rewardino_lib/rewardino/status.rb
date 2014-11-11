module Rewardino
  class Status
    attr_reader :badge

    def initialize badge=nil
      @badge = badge
    end
  end

  class StatusAwarded < Status; end
  class StatusAlreadyAwarded < Status; end
  class StatusNotAwarded < Status; end
  class StatusTakenAway < Status; end
  class StatusError < Status; end
end
