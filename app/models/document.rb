class Document < Attachment
  mount_uploader :file, DocumentUploader

  def file_name
    File.basename file_url if file_url
  end
end
