class BlogPostObserver < ActiveRecord::Observer
  include BroadcastObserver
end