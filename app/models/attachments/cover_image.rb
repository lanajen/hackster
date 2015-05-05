class CoverImage < BaseImage
  VERSIONS = {
    cover: { w: 1600, h: 1200 },
    cover_wide: { w: 1600, h: 460 },
    cover_thumb: { w: 400, h: 300 },
    cover_mini_thumb: { w: 60, h: 60 },
  }
  mount_uploader :file, CoverImageUploader
end