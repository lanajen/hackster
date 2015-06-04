class Store::ProductsController < Store::BaseController
  skip_before_filter :authenticate_user!

  def index
    @products = StoreProduct.available.paginate(page: safe_page_params)
  end
end