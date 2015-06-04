class Admin::Store::ProductsController < Admin::BaseController
  def index
    title "Admin / Store / Products - #{safe_page_params}"
    @fields = {
      'created_at' => 'store_products.created_at',
      'available' => 'store_products.available',
    }

    params[:sort_by] ||= 'created_at'

    @products = filter_for StoreProduct, @fields
  end

  def new
    @product = StoreProduct.new
  end

  def create
    @product = StoreProduct.new(params[:store_product])

    if @product.save
      redirect_to admin_store_products_path, :notice => 'New product created'
    else
      render :new
    end
  end

  def edit
    @product = StoreProduct.find(params[:id])
  end

  def update
    @product = StoreProduct.find(params[:id])

    if @product.update_attributes(params[:store_product])
      redirect_to admin_store_products_path, :notice => 'StoreProduct successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @product = StoreProduct.find(params[:id])
    @product.destroy
    redirect_to admin_store_products_path, :notice => 'StoreProduct successfuly deleted'
  end
end