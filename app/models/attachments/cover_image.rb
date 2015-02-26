class CoverImage < Attachment
  mount_uploader :file, CoverImageUploader

  before_save :truncate_title

  private
    def truncate_title
      self.title = title.truncate 255 if title
    end
end