class DiscussionObserver < ActiveRecord::Observer
  include BroadcastObserver
end