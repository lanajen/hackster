# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper

  if Rails.env.in? %w(production staging dev) or ENV['CARRIERWAVE_FORCE_FOG'] == 'true'
    storage :fog
  else
    storage :file
  end

  def extension_white_list
    nil
  end

  def needs_processing?
    false
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
