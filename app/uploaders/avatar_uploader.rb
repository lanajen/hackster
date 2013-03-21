# encoding: utf-8

class AvatarUploader < BaseUploader
  # Create different versions of your uploaded files:
  version :tiny do
    process :resize_to_fill => [20, 20]
  end
  version :mini do
    process :resize_to_fill => [40, 40]
  end
  version :thumb do
    process :resize_to_fill => [60, 60]
  end
  version :medium do
    process :resize_to_fill => [80, 80]
  end
  version :big do
    process :resize_to_fill => [180, 180]
  end
end
