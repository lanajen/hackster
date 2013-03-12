# encoding: utf-8

class ImageUploader < BaseUploader
  # Create different versions of your uploaded files:
  version :headline do
    process :resize_to_fill => [560, 420]
  end
  version :thumb do
    process :resize_to_fill => [200, 150]
  end
end
