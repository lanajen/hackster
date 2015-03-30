# encoding: utf-8

class CoverImageUploader < BaseImageUploader

  # process :convert_gifs

  version :cover do
    process resize_to_fill: [1600, 1200]
    # process resize_to_fit: [1600, 1200]
    # process resize_and_pad: [1600, 1200, '#ffffff']
  end

  version :cover_wide do
    process resize_to_fill: [1600, 460]
  end

  version :cover_thumb, from_version: :cover do
    process resize_to_fill: [400, 300]
  end

  version :cover_mini_thumb do
    process resize_to_fill: [60, 60]
  end

  # def convert_gifs
  #   manipulate! do |img|
  #     img.format('png')
  #   end
  # end
end
