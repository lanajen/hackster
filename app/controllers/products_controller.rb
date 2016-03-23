class ProductsController < ApplicationController
  respond_to :html

  def show
    not_found

    @product = Product.find_by_slug!(params[:slug]).decorate
    impressionist_async @product, '', unique: [:session_hash]
    title @product.name
    meta_desc @product.one_liner
    @can_edit = (can? :edit, @product)

    # track_event 'Viewed product', @product.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @product) })
  end
end