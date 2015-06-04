class Store::OrdersController < Store::BaseController
  def index
    @orders = current_user.orders.not_new
  end

  def show
    @order = Order.find params[:id]
    authorize! :read, @order

    @product = @order.order_lines.first.store_product.source
    @message_facebook = "I'm getting a free #{@product.name} thanks to Hackster.io!"
    @message_twitter = "I'm getting a free #{@product.name} thanks to @hacksterio!"
    @order = @order.decorate
  end

  def update
    authorize! :update, current_order
    not_found and return unless current_order.id.to_s == params[:id]

    if current_order.update_attributes params[:order]
      redirect_to store_cart_index_path, notice: "Order updated."
    else
      redirect_to store_cart_index_path, alert: "Couldn't update order."
    end
  end

  def confirm
    authorize! :update, current_order
    not_found and return unless current_order.id.to_s == params[:id]

    begin
      current_order.pass_order!
      redirect_to store_order_path(current_order)
    rescue Workflow::TransitionHalted
      redirect_to store_cart_index_path, alert: "Couldn't place order: #{current_order.halted_because}."
    end
  end
end