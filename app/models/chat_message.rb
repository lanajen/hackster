class ChatMessage < ActiveRecord::Base
  self.table_name = :threads

  belongs_to :group
  belongs_to :user

  attr_accessible :user_id, :group_id, :body, :created_at
  attr_accessor :group_id
end
