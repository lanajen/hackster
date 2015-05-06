class Client::BaseController < ApplicationController
  before_filter :authenticate

  protected
    def authenticate
      unless authenticate_with_http_basic { |u, p| u == current_platform.user_name and p == current_platform.http_password }
        request_http_basic_authentication
      end if current_platform and current_platform.enable_password
    end

    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{current_platform.mini_resume} Come explore #{current_platform.name} projects!"
      end
    end
end