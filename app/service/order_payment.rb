class OrderPayment
  def configure
    payment = @order.payment || @order.build_payment
    payment.assign_attributes payment_attributes
    payment.save
  end

  def initialize order
    @order = order
  end

  private
    def amount
      (@order.shipping_cost_in_currency.to_f / (1 + Payment::CREDIT_CARD_RATE)).round(2)
    end

    def invoice_number
      "order_#{@order.id}"
    end

    def payment_label
      "Shipping for Hackster (Free) Store order"
    end

    def payment_attributes
      {
        amount: amount,
        recipient_name: @order.user.try(:name),
        recipient_email: @order.user.try(:email),
        invoice_number: invoice_number,
        label: payment_label,
      }
    end
end