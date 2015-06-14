class Admin::Store::OrdersController < Admin::BaseController
  def index
    title "Admin / Store / Orders - #{safe_page_params}"
    @fields = {
      'created_at' => 'orders.created_at',
      'status' => 'orders.workflow_state',
    }

    params[:sort_by] ||= 'created_at'

    @orders = filter_for Order, @fields
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])

    if @order.save
      redirect_to admin_store_orders_path, :notice => 'New order created'
    else
      render :new
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    if @order.update_attributes(params[:order])
      redirect_to admin_store_orders_path, :notice => 'Order successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to admin_store_orders_path, :notice => 'Order successfuly deleted'
  end
end