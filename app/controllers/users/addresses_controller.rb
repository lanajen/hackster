class Users::AddressesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @addresses = current_user.addresses.visible

    redirect_to new_address_path(order_id: params[:order_id], entry_id: params[:entry_id]) and return if params[:redirect_if_empty] and @addresses.empty?
  end

  def new
    @address = current_user.addresses.new
  end

  def create
    @address = current_user.addresses.new params[:address]

    if @address.save
      redirect_to addresses_path(order_id: params[:order_id], entry_id: params[:entry_id]), notice: 'Address saved.'
    else
      render :new
    end
  end

  def update
    @address = current_user.addresses.find params[:id]

    if @address.update_attributes params[:address]
      redirect_to addresses_path(order_id: params[:order_id], entry_id: params[:entry_id]), notice: 'Address saved.'
    else
      redirect_to addresses_path(order_id: params[:order_id], entry_id: params[:entry_id]), alert: "Couldn't update address."
    end
  end

  def destroy
    @address = current_user.addresses.find params[:id]

    @address.update_attribute :deleted, true

    redirect_to addresses_path(order_id: params[:order_id], entry_id: params[:entry_id]), notice: 'Address deleted.'
  end
end