class Broadcast < ActiveRecord::Base
  attr_accessible :context_model_id, :event, :context_model_type
  belongs_to :broadcastable, polymorphic: true

  def context_model
    @context_model ||= context_model_type.constantize.find_by_id context_model_id
  end
end
