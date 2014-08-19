class Admin::QuotesController < Admin::BaseController
  respond_to :html
  load_resource

  def index
    @quotes = Quote.order(:id).paginate(:page => safe_page_params)
  end

  def new
  end

  def create
    if @quote.save
      redirect_to admin_quotes_path, :notice => 'New quote created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @quote.update_attributes(params[:quote])
      redirect_to admin_quotes_path, :notice => 'Quote successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @quote.destroy
    redirect_to admin_quotes_path, :notice => 'Quote successfuly deleted'
  end
end