class Image < BaseImage
  VERSIONS = {
    lightbox: { w: 1280, h: 960 },
    headline: { w: 580, h: 435 },
    thumb: { w: 200, h: 150 },
  }
  mount_uploader :file, ImageUploader
end