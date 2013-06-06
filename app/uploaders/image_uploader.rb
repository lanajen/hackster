# encoding: utf-8

class ImageUploader < BaseUploader
  version :headline do
    process resize_to_fill: [580, 435]
  end
  version :headline_orig do
    process resize_and_pad: [580, 435, :transparent, Magick::CenterGravity]
#    process resize_to_limit_and_pad: [580, 435, :transparent, Magick::CenterGravity]
  end
  version :thumb, from_version: :headline do
    process resize_to_fill: [200, 150]
  end
  version :small_thumb, from_version: :thumb do
    process resize_to_fill: [140, 105]
  end

  def resize_to_limit_and_pad(width, height, background=:transparent, gravity=::Magick::CenterGravity)
    manipulate! do |img|
      img = img.resize_to_limit(width, height)
      new_img = ::Magick::Image.new(width, height)
      if background == :transparent
        filled = new_img.matte_floodfill(1, 1)
      else
        filled = new_img.color_floodfill(1, 1, ::Magick::Pixel.from_color(background))
      end
      destroy_image(new_img)
      filled.composite!(img, gravity, ::Magick::OverCompositeOp)
      destroy_image(img)
      filled = yield(filled) if block_given?
      filled
    end
  end
end
