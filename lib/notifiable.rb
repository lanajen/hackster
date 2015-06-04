module Notifiable
  def self.included base
    base.send :has_many, :notifications, as: :notifiable, dependent: :destroy
  end
end