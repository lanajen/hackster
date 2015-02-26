# encoding: utf-8

class ImageUploader < BaseImageUploader

  version :lightbox do
    process resize_to_limit: [1280, 960]
  end

  version :headline do
    process resize_to_limit: [580, 435]
  end

  version :thumb, from_version: :headline do
    process resize_to_limit: [200, 150]
  end

end
