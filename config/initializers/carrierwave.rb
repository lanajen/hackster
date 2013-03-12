#conf = YAML::load(File.open(File.join(Rails.root, 'config', 'server', 's3.yml')))
#
#CarrierWave.configure do |config|
#  config.fog_credentials = {
#    :provider               => 'AWS',       # required
#    :aws_access_key_id      => conf['aws_access_key_id'],       # required
#    :aws_secret_access_key  => conf['aws_secret_access_key'],       # required
#    :region                 => conf['region'],  # optional, defaults to 'us-east-1'
#  }
#  config.fog_directory  = conf['directory']                     # required
#  config.fog_host       = conf['host']            # optional, defaults to nil
#  config.fog_public     = false                                   # optional, defaults to true
#  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
#end
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => ENV['FOG_PROVIDER'],       # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],       # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],       # required
    :region                 => ENV['FOG_REGION'],  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['FOG_DIRECTORY']                    # required
  config.asset_host       = ENV['FOG_HOST']            # optional, defaults to nil
  config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end