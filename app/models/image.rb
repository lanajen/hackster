class Image < Attachment
  mount_uploader :file, ImageUploader
end
