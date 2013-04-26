class PublicationObserver < ActiveRecord::Observer
  include BroadcastObserver
end