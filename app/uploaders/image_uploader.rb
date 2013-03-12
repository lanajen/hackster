# encoding: utf-8

class ImageUploader < BaseUploader
  version :headline do
    process resize_to_fill: [580, 326]
  end
  version :thumb do
    process resize_to_fill: [200, 150]
  end
  version :small_thumb do
    process resize_to_fill: [140, 105]
  end
end
