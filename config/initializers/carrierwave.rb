# ENV['TMP'] = File.join(Rails.root, 'tmp')

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => ENV['FOG_PROVIDER'],       # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],       # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],       # required
    :region                 => ENV['FOG_REGION'],  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['FOG_DIRECTORY']                    # required
  config.asset_host     = ENV['FOG_HOST']            # optional, defaults to nil
  config.fog_public     = true                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

  config.cache_dir = 'carrierwave'
  config.root = Rails.root.join('tmp')
end if Rails.env.in? %w(production staging) or ENV['CARRIERWAVE_FORCE_FOG'] == 'true'