class ImageDecorator < ApplicationDecorator
  def file_url size=nil
    if model.file_url
      model.file_url(size)
    elsif model.tmp_file
      h.asset_url "project_cover_image_processing.png"
    end
  end
end