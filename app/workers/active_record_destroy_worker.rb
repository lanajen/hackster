class ActiveRecordDestroyWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def destroy class_name, id
    model = class_name.constantize.find id
    model.destroy
  end
end