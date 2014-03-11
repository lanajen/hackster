class PostObserver < ActiveRecord::Observer
  include BroadcastObserver

  private
    def project_id record
      record.threadable_id
    end
end