ActiveRecord::Base.class_eval do
  def destroy_async
    update_column :destroyed, true if respond_to? :destroyed
    ActiveRecordDestroyWorker.perform_async 'destroy', self.class.name, id
  end
end