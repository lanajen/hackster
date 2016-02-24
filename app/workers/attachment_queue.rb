class AttachmentQueue < BaseWorker
  sidekiq_options queue: :critical, retry: 1

  def process id
    attachment = Attachment.find_by_id(id)

    attachment.process if attachment
  end

  def remote_upload id, url
    a = Attachment.find(id)
    a.remote_file_url = url
    if a.save
      a.notify_observers :after_process
    end
  end
end