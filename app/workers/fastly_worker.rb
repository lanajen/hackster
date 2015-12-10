class FastlyWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def purge *keys
    keys.each do |key|
      FastlyRails.purge_by_key key
    end
  end
end