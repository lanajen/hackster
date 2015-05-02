class ReputationEvent < ActiveRecord::Base
  belongs_to :event_model, polymorphic: true
  belongs_to :user

  attr_protected  # none
end
