# encoding: utf-8

class ImageUploader < BaseUploader
  version :lightbox, unless: :is_cover? do
    process resize_to_limit: [1280, 960]
  end

  version :headline, unless: :is_cover? do
    process resize_to_fill: [580, 435]
  end

  version :headline_orig, unless: :is_cover? do
    process resize_to_limit_and_pad: [580, 435, :transparent, Magick::CenterGravity]
  end

  version :thumb, from_version: :headline, unless: :is_cover? do
    process resize_to_fill: [200, 150]
  end

  version :small_thumb, from_version: :thumb, unless: :is_cover? do
    process resize_to_fill: [140, 105]
  end

  version :cover, if: :is_cover? do
    process resize_to_fill: [600, 450]
  end

  version :cover_thumb, if: :is_cover? do
    process resize_to_fill: [213, 160]
  end

  # resize_and_pad that doesn't make pictures any bigger than what they already are
  def resize_to_limit_and_pad(width, height, background=:transparent, gravity=::Magick::CenterGravity)
    manipulate! do |img|
      geometry = Magick::Geometry.new(width, height, 0, 0, Magick::GreaterGeometry)
      new_img = img.change_geometry(geometry) do |new_width, new_height|
        img.resize(new_width, new_height)
      end
      destroy_image(img)
      new_img = yield(new_img) if block_given?
      img = new_img
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

  protected
    def is_cover? picture
      model.class == CoverImage
    end
end
