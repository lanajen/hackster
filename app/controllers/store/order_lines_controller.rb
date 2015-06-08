class Store::OrderLinesController < Store::BaseController
  def index
    authorize! :read, current_order
    @order_lines = current_order.order_lines
  end

  def create
    authorize! :update, current_order
    @product = StoreProduct.find params[:store_product_id]

    if current_order.add_to_cart @product
      redirect_to store_cart_index_path, notice: "#{@product.source.name} is now in your cart."
    else
      redirect_to store_path, alert: "Couldn't add #{@product.source.name} to your cart because #{@product.errors[:cart].to_sentence}"
    end
  end

  def destroy
    authorize! :update, current_order

    @order_line = OrderLine.find params[:id]
    @order_line.destroy

    redirect_to store_cart_index_path, notice: "#{@order_line.store_product.source.name} was removed from your cart."
  end
end