class Image < Attachment
  mount_uploader :file, ImageUploader

  before_save :truncate_title

  private
    def truncate_title
      self.title = title.truncate 255 if title
    end
end
