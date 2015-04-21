class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true
  has_many :receipts, as: :receivable

  # validates :event, uniqueness: { scope: [:notifiable_id, :notifiable_type] }

  attr_accessible :event, :notifiable
  attr_accessor :context

  def self.generate event, context
    notif = new event: event, notifiable: context[:model]
    notif.context = context
    notif.save
  end

  def recipients
    return [] unless @context

    @context[:users] || [@context[:user]]
  end
end