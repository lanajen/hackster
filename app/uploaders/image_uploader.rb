# encoding: utf-8

class ImageUploader < BaseUploader

  version :lightbox, unless: :is_cover? do
    process resize_to_limit: [1280, 960]
  end

  version :headline, unless: :is_cover? do
    process resize_to_limit: [580, 435]
  end

  version :thumb, from_version: :headline, unless: :is_cover? do
    process resize_to_limit: [200, 150]
  end

  version :cover, if: :is_cover? do
    process resize_to_fill: [600, 450]
  end

  version :cover_thumb, from_version: :cover, if: :is_cover? do
    process resize_to_fill: [220, 165]
  end

  version :cover_mini_thumb, if: :is_cover? do
    process resize_to_fill: [60, 60]
  end

  def extension_white_list
    %w(gif png jpg jpeg ico bmp) unless model.skip_file_check?
  end

  def needs_processing?
    true
  end

  protected
    def is_cover? picture
      model.class == CoverImage
    end
end
