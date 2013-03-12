class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_authorization_for_admin

  layout 'layouts/admin'

  private
    def check_authorization_for_admin
      raise CanCan::AccessDenied unless current_user.is? :admin
    end
end
