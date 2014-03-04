class Broadcast < ActiveRecord::Base
  attr_accessible :context_model_id, :event, :context_model_type, :user_id, :project_id
  belongs_to :broadcastable, polymorphic: true
  belongs_to :project
  belongs_to :user

  def context_model
    @context_model ||= context_model_type.constantize.find_by_id context_model_id
  end

  def fingerprint
    "#{broadcastable_type}_#{broadcastable_id}_#{context_model_type}_#{context_model_id}"
  end
end
