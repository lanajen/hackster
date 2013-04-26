class CommentObserver < ActiveRecord::Observer
  include BroadcastObserver
end