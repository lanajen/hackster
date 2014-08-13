class PostObserver < BaseBroadcastObserver

  private
    def project_id record
      record.threadable_id
    end
end