class Image < BaseImage
  DEFAULT_CAPTION = "caption (optional)"

  VERSIONS = {
    lightbox: { w: 1280, h: 960, fit: :max },
    headline: { w: 680, h: 510, fit: :max },
    medium: { w: 400, h: 300, fit: :max },
    medium_fill: { w: 400, h: 300, fit: :fill, bg: 'ffffff' },
    thumb: { w: 200, h: 150, fit: :max },
    part_thumb_big: { w: 140, h: 140, fit: :fill, bg: 'ffffff' },
    part_thumb_big_arduino: { w: 140, h: 140, fit: :fill, bg: 'f4f4f4' },
    part_thumb: { w: 48, h: 48, fit: :fill, bg: 'ffffff' },
    mini_thumb: { w: 48, h: 36, fit: :max },
    tiny: { w: 20, h: 20, fit: :max },
  }
  mount_uploader :file, ImageUploader
end