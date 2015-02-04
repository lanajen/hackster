# encoding: utf-8

class ImageUploader < BaseUploader
  EXTENSION_WHITE_LIST = %w(gif png jpg jpeg ico bmp)

  process :fix_exif_rotation

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
    process resize_to_limit: [1600, 1200]
  end

  version :cover_thumb, from_version: :cover, if: :is_cover? do
    process resize_to_fill: [400, 300]
  end

  version :cover_mini_thumb, if: :is_cover? do
    process resize_to_fill: [60, 60]
  end

  def extension_white_list
    EXTENSION_WHITE_LIST unless model.skip_file_check?# or model.skip_extension_check
  end

  def needs_processing?
    true
  end

  protected
    def fix_exif_rotation #this is my attempted solution
      manipulate! do |img|
        img.tap(&:auto_orient)
      end
    rescue
    end

    def is_cover? picture
      model.class == CoverImage
    end
end
