class Document < Attachment
  mount_uploader :file, DocumentUploader
end
