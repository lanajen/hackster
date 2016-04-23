require 'yaml'

class Mouser::BaseController < ActionController::Base
  CONFIG_FILE = File.join(Rails.root, 'config', 'mouser.yml')

  layout 'mouser'
  helper_method :active_phase
  helper_method :meta_desc
  helper_method :title
  helper_method :api_host

  private
    def active_phase
     @active_phase ||= redis.get('active_phase').present? ? redis.get('active_phase').to_i : -1
    end

    def config
      @config ||= YAML.load File.open(CONFIG_FILE)
    end

    def initialize_vendor_from_hash hash
      attributes = {}
      hash.each{ |k, v| attributes[k.to_sym] = v }
      Mouser::Vendor.new(attributes)
    end

    def load_phases
      @phases = config['phases'].values
    end

    def load_vendor user_name, index=0
      vendor = nil
      vendor_data = config['vendors']
      vendor_data.each_with_index do |v, i|
        if v['user_name'] == user_name
          new_index = i + index
          if (new_index + 1) > vendor_data.length
            new_index = 0
          elsif new_index < 0
            new_index = vendor_data.length - 1
          end
          vendor = initialize_vendor_from_hash(vendor_data[new_index])
          break
        end
      end
      raise ActiveRecord::NotFound if vendor.blank?
      vendor
    end

    def load_vendors
      vendor_data = config['vendors']
      @vendors = []
      vendor_data.each do |attrs|
        @vendors << initialize_vendor_from_hash(attrs)
      end
      @vendors
    end

    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      elsif @meta_desc
        @meta_desc
      else
        @meta_desc = 'Mouser Summer Contest'
      end
    end

    def redis
      @redis ||= Redis::Namespace.new('mouser', redis: RedisConn.conn)
    end

    def title title=nil
      if title
        @title = title
      elsif @title
        @title
      else
        @title = 'Mouser Summer Contest'
      end
    end

    def api_host
     'mousercontest.' + APP_CONFIG['default_domain']
    end
end