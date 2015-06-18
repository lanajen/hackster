class Admin::PaymentsController < Admin::BaseController
  load_resource

  def index
    title "Admin / Payments - #{safe_page_params}"
    @fields = {
      'created_at' => 'payments.created_at',
      'status' => 'payments.workflow_state',
      'name' => 'payments.recipient_name',
      'email' => 'payments.recipient_email',
    }

    params[:sort_order] ||= 'DESC'

    @payments = filter_for Payment, @fields
  end

  def new
  end

  def create
    if @payment.save
      redirect_to payment_path(@payment.safe_id), notice: "Copy paste the current URL and send it to the customer."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @payment.update_attributes(params[:payment])
      redirect_to payment_path(@payment.safe_id), notice: "Copy paste the current URL and send it to the customer."
    else
      render :edit
    end
  end

  def update_workflow
    @payment = Payment.find params[:id]

    if @payment.send "#{params[:event]}!"
      flash[:notice] = "Payment state changed to: #{@payment.workflow_state}."
      redirect_to admin_payments_path
    else
      render :edit
    end
  end

  def destroy
    @payment = Payment.find params[:id]
    @payment.destroy
    redirect_to admin_payments_path, notice: "Deleted"
  end
end