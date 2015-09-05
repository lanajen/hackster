class Image < BaseImage
  VERSIONS = {
    lightbox: { w: 1280, h: 960, fit: :max },
    headline: { w: 580, h: 435, fit: :max },
    medium: { w: 400, h: 300, fit: :max },
    thumb: { w: 200, h: 150, fit: :max },
  }
  mount_uploader :file, ImageUploader
end