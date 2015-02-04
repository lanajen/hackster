class AttachmentQueue < BaseWorker
  sidekiq_options queue: :critical, retry: 1

  def process id
    attachment = Attachment.find_by_id(id)

    # raise NotFound unless attachment

    attachment.process if attachment
  end

  def remote_upload id, url
    a = Attachment.find(id)
    a.remote_file_url = url
    a.save
    a.notify_observers :after_process
  end

  class NotFound < StandardError; end
end