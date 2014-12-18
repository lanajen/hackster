class Conversation < ActiveRecord::Base
  has_many :messages, -> { order(created_at: :asc) }, as: :commentable, class_name: 'Comment'
  has_many :receipts

  validates :subject, :body, :sender_id, :recipient_id, presence: true,
    on: :create
  validates :body, :sender_id, presence: true, on: :update
  after_create :create_message
  after_update :create_reply

  attr_accessor :recipient_id, :sender_id, :body
  attr_accessible :subject, :recipient_id, :sender_id, :body

  def self.inbox_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false }).joins("INNER JOIN comments ON comments.id = receipts.message_id").where.not(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def self.sent_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false }).joins("INNER JOIN comments ON comments.id = receipts.message_id").where(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def self.unread_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false, read: false }).joins("INNER JOIN comments ON comments.id = receipts.message_id").where.not(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def first_unread_message_for user
    receipts.unread.where(user_id: user.id).first
  end

  def has_unread? user
    receipts.unread.where(user_id: user.id).any?
  end

  def last_message user=nil, box=nil
    @last_message ||= if user.nil? and box.nil?
      messages.last
    elsif box == 'inbox'
      messages.where.not(comments: { user_id: user.id }).last
    else
      messages.where(comments: { user_id: user.id }).last
    end
  end

  def mark_as_read! user
    receipts.unread.where(user_id: user.id).update_all(read: true)
  end

  def move_to_trash! user
    receipts.where(user_id: user.id).update_all(deleted: true)
  end

  def participants
    # @participants ||=
    User.joins(:conversations).where(conversations: { id: id })
  end

  private
    def create_message
      message = messages.new body: body
      message.user_id = sender_id
      message.save
      receipts.create user_id: recipient_id, message_id: message.id
      receipts.create user_id: sender_id, message_id: message.id, read: true
    end

    def create_reply
      message = messages.new body: body
      message.user_id = sender_id
      message.save
      recipient_id = participants.where.not(users: { id: sender_id }).first.id
      receipts.create user_id: recipient_id, message_id: message.id
      receipts.create user_id: sender_id, message_id: message.id, read: true
    end
  end