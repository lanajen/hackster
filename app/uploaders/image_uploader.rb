# encoding: utf-8

class ImageUploader < BaseUploader
  version :headline do
    process resize_to_fill: [580, 435]
  end
  version :headline_orig do
    process resize_and_pad: [580, 435, :transparent, Magick::CenterGravity]
  end
  version :thumb, from_version: :headline do
    process resize_to_fill: [200, 150]
  end
  version :small_thumb, from_version: :thumb do
    process resize_to_fill: [140, 105]
  end
end
