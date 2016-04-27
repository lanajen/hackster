class UserWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def destroy record_id
    User.find(record_id).destroy_now
  end
end