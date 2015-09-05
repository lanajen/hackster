class CoverImage < BaseImage
  VERSIONS = {
    cover: { w: 1600, h: 1200, fit: :min },
    cover_wide: { w: 1600, h: 460, fit: :min },
    cover_wide_large: { w: 900, h: 200, fit: :min },
    cover_wide_small: { w: 450, h: 130, fit: :min },
    cover_wide_mini: { w: 300, h: 75, fit: :min },
    large: { w: 900, h: 675, fit: :min },
    cover_thumb: { w: 400, h: 300, fit: :min },
    cover_mini_thumb: { w: 60, h: 60, fit: :min },
  }
  mount_uploader :file, CoverImageUploader
end