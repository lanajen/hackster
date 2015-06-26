class PaymentsController < ApplicationController
  def show
    @payment = Payment.find_by_safe_id! params[:safe_id]
  end

  def create
    @payment = Payment.find_by_safe_id! params[:safe_id]

    begin
      if @payment.charge!(params[:stripeToken])
        flash[:notice] = "All good, thank you for your payment!"
      else
        flash[:alert] = "Something went wrong with your payment: #{@payment.sripe_errors.to_sentence}."
      end
    rescue Workflow::NoTransitionAllowed, Workflow::TransitionHalted
      if @payment.paid?
        flash[:notice] = "This payment has already been made."
      else
        flash[:notice] = "Something's not quite right, please contact Ben at ben@hackster.io. #{@payment.sripe_errors.to_sentence}"
      end
    end

    redirect_to payment_path(@payment.safe_id)
  end
end