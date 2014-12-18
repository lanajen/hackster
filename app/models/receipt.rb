class Receipt < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :message, class_name: 'Comment'
  belongs_to :user

  attr_accessible :user_id, :message_id, :read

  def self.unread
    where(read: false)
  end

  def deleted?
    deleted
  end

  def is_read?
    read
  end

  def is_sender? user
    message.user == user
  end

  def is_unread?
    !is_read?
  end
end
