module AfterCommitCallbacks
  def after_commit record
    action = record.destroyed? ? "destroy" : (record.send(:transaction_record_state, :new_record) ? "create" : "update")

    send :"after_commit_on_#{action}", record if self.class.method_defined?(:"after_commit_on_#{action}")

    true
  rescue Exception => ex
    p ex
    raise ex
  end
end

ActiveRecord::Observer.class_eval do
  include AfterCommitCallbacks
end