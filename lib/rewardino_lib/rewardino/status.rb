module Rewardino
  class Status
    attr_reader :badge

    def initialize awarded_badge=nil
      @awarded_badge = awarded_badge
      @badge = awarded_badge.try(:badge)
    end
  end

  class StatusAwarded < Status; end
  class StatusAlreadyAwarded < Status; end
  class StatusNotAwarded < Status; end
  class StatusTakenAway < Status; end
  class StatusError < Status; end
end
