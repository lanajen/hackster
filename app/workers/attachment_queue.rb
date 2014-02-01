class AttachmentQueue < BaseWorker
  @queue = :attachments

  def process id
    Attachment.find(id).process
  end
end