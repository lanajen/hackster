class Avatar < BaseImage
  VERSIONS = {
    tiny: { w: 20, h: 20, fit: :min },
    mini: { w: 40, h: 40, fit: :min },
    thumb: { w: 60, h: 60, fit: :min },
    medium: { w: 80, h: 80, fit: :min },
    large: { w: 120, h: 120, fit: :min },
    big: { w: 200, h: 200, fit: :min },
  }
  mount_uploader :file, AvatarUploader
end