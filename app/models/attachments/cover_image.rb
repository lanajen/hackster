class CoverImage < BaseImage
  VERSIONS = {
    cover: { w: 1600, h: 1200, fit: :crop },
    cover_wide: { w: 1600, h: 460, fit: :crop },
    cover_thumb: { w: 400, h: 300, fit: :crop },
    cover_mini_thumb: { w: 60, h: 60, fit: :crop },
  }
  mount_uploader :file, CoverImageUploader
end