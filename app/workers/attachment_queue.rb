class AttachmentQueue < BaseWorker
  sidekiq_options queue: :critical, retry: false

  def process id
    a = Attachment.find_by_id id
    a.process if a
  end
end