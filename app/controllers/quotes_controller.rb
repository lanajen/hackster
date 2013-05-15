class QuotesController < ApplicationController
  skip_before_filter :authenticate_user_with_key_or_login!
  load_resource
  respond_to :html
  layout 'quotes'

  def new
    @quote.documents.new
  end

  def create
    if @quote.save
      redirect_to quote_requested_path
    else
      render action: 'new'
    end
  end

  def requested

  end
end