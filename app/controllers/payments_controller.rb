class PaymentsController < ApplicationController
  def show
    @payment = Payment.find_by_safe_id! params[:safe_id]
  end

  def create
    @payment = Payment.find_by_safe_id! params[:safe_id]

    case @payment.payable_type
    when 'Order'
      okay_url = confirm_store_orders_path(id: @payment.payable_id)
      error_url = store_cart_index_path
    else
      okay_url = error_url = payment_path(@payment.safe_id)
    end

    next_url = nil
    status = nil

    next_url = begin
      status = 'ok'
      if @payment.charge!(params[:stripeToken])
        flash[:notice] = "All good, thank you for your payment!"
        okay_url
      else
        flash[:alert] = "Something went wrong with your payment: #{@payment.sripe_errors.to_sentence}."
        error_url
      end
    rescue Workflow::NoTransitionAllowed, Workflow::TransitionHalted => e
      status = 'error'
      puts "Error while processing payment: #{e.message}"
      if @payment.paid?
        flash[:notice] = "This payment has already been made."
        okay_url
      else
        flash[:notice] = "Something's not quite right, please contact Ben at ben@hackster.io. #{@payment.stripe_errors.to_sentence}"
        error_url
      end
    end

    respond_to do |format|
      format.html do
        redirect_to next_url
      end
      format.json do
        render json: { redirect_to: next_url, message: (flash[:notice] || flash[:alert]), status: status }
        flash.clear
      end
    end
  end
end