class AttachmentQueue < BaseWorker
  sidekiq_options queue: :critical, retry: false

  def process id
    Attachment.find(id).process
  end
end