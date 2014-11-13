class AttachmentQueue < BaseWorker
  sidekiq_options queue: :critical, retry: false

  def process id
    Attachment.find(id).process
  end

  def remote_upload id, url
    a = Attachment.find(id)
    a.remote_file_url = url
    a.save
    a.notify_observers :after_process
  end
end