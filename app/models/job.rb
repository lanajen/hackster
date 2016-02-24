class Job < ActiveRecord::Base
  include Workflow

  belongs_to :platform

  is_impressionable counter_cache: true, column_name: :clicks_count, unique: :session_hash

  workflow do
    state :new
    state :active
    state :fulfilled
  end

  def self.active
    where workflow_state: :active
  end
end
