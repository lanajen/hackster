class ChatMessage < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  attr_accessible :user_id, :group_id, :body, :created_at
  validates :user_id, :group_id, presence: true
end
