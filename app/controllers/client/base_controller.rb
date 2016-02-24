class Client::BaseController < ApplicationController
  before_filter :authenticate

  protected
    def authenticate
      authorize_access! current_platform.user_name, current_platform.http_password if current_platform and current_platform.enable_password
    end

    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{current_platform.mini_resume} Come explore #{current_platform.name} projects!"
      end
    end
end