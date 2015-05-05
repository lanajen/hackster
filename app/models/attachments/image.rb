class Image < BaseImage
  VERSIONS = {
    lightbox: { w: 1280, h: 960, fit: :clip },
    headline: { w: 580, h: 435, fit: :clip },
    thumb: { w: 200, h: 150, fit: :clip },
  }
  mount_uploader :file, ImageUploader
end