class Payment < ActiveRecord::Base
  include HstoreColumn
  include Workflow
  CREDIT_CARD_RATE = 0.03
  UNPAID_STATES = %w(new sent)

  attr_accessible :recipient_name, :invoice_number, :recipient_email, :amount,
    :stripe_token

  validates :recipient_name, :label, :recipient_email, :amount, presence: true

  belongs_to :payable, polymorphic: true

  hstore_column :properties, :label, :string
  hstore_column :properties, :paid_at, :datetime
  before_create :generate_safe_id

  workflow do
    state :new do
      event :send_email, transitions_to: :sent
      event :charge, transitions_to: :paid
    end
    state :sent do
      event :charge, transitions_to: :paid
    end
    state :paid
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def charge token
    begin
      charge = Stripe::Charge.create(
        amount: stripe_amount,
        currency: "USD",
        source: token,
        description: label,
        receipt_email: recipient_email
      )
      update_attributes paid_at: Time.now, stripe_token: token
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      puts "Stripe error: #{e.message}"
      halt!
      @stripe_errors = [e.message]
    end
  end

  def credit_card_fee
    (amount.to_f * CREDIT_CARD_RATE).round(2)
  end

  def unpaid?
    workflow_state.in? UNPAID_STATES
  end

  def stripe_amount
    (total_amount * 100).to_i
  end

  def stripe_errors
    @stripe_errors ||= []
  end

  def total_amount
    (amount.to_f + credit_card_fee).round(2)
  end

  private
    def generate_safe_id
      self.safe_id = SecureRandom.urlsafe_base64
    end
end