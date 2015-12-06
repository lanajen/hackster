class Receipt < ActiveRecord::Base
  include Notifiable

  belongs_to :receivable, polymorphic: true
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :delete_all

  attr_accessible :user_id, :receivable_id, :receivable_type, :read

  def self.unread
    where(read: false)
  end

  def association_name_for_notifications
    receivable_type
  end

  def deleted?
    deleted
  end

  def is_read?
    read
  end

  def is_sender? user
    receivable.user == user
  end

  def is_unread?
    !is_read?
  end
end
