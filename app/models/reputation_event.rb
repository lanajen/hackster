class ReputationEvent < ActiveRecord::Base
  belongs_to :event_model, polymorphic: true
  belongs_to :user

  attr_protected  # none

  validates :event_name, uniqueness: { scope: [:event_model_type, :event_model_id, :points, :user_id] }

  def event
    @event ||= Rewardino::Event.find(event_name)
  end
end
