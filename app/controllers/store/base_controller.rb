class Store::BaseController < ApplicationController
  before_filter :authenticate_user!
  helper_method :current_order
  layout 'store'

  private
    def current_order
      return @current_order if @current_order

      @current_order = current_user.orders.where(workflow_state: :new).first_or_create do |order|
        order.address = current_user.addresses.default
      end
    end
end