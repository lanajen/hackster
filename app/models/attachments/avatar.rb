class Avatar < BaseImage
  VERSIONS = {
    tiny: { w: 20, h: 20 },
    mini: { w: 40, h: 40 },
    thumb: { w: 60, h: 60 },
    medium: { w: 80, h: 80 },
    big: { w: 200, h: 200 },
  }
  mount_uploader :file, AvatarUploader
end