class Avatar < BaseImage
  VERSIONS = {
    tiny: { w: 20, h: 20, fit: :crop },
    mini: { w: 40, h: 40, fit: :crop },
    thumb: { w: 60, h: 60, fit: :crop },
    medium: { w: 80, h: 80, fit: :crop },
    big: { w: 200, h: 200, fit: :crop },
  }
  mount_uploader :file, AvatarUploader
end