# encoding: utf-8

class BaseImageUploader < BaseUploader
  EXTENSION_WHITE_LIST = %w(gif png jpg jpeg ico bmp)

  # process :fix_exif_rotation

  def extension_white_list
    EXTENSION_WHITE_LIST unless model.skip_file_check?# or model.skip_extension_check
  end

  def needs_processing?
    false
  end

  protected
    def fix_exif_rotation #this is my attempted solution
      manipulate! do |img|
        img.tap(&:auto_orient)
      end
    rescue
    end
end
