class Conversation < ActiveRecord::Base
  has_many :messages, -> { order(created_at: :asc) }, as: :commentable, class_name: 'Comment', dependent: :destroy
  has_many :receipts, through: :messages, dependent: :destroy
  has_many :users, through: :messages, source: :user

  validates :subject, :body, :sender_id, :recipient_id, presence: true,
    on: :create
  validates :body, :sender_id, presence: true, on: :update
  validate :subject_is_unique, on: :create
  validate :sender_is_not_spamming, on: :create
  after_create :create_message
  after_update :create_reply

  attr_accessor :recipient_id, :sender_id, :body, :is_spam
  attr_accessible :subject, :recipient_id, :sender_id, :body

  def self.for user
    where(id: joins(:receipts).where(receipts: { user_id: user.id, deleted: false }).distinct('conversations.id').pluck(:id)).order("conversations.updated_at DESC")
  end

  def self.inbox_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false }).where.not(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def self.sent_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false }).where(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def self.unread_for user
    joins(:receipts).where(receipts: { user_id: user.id, deleted: false, read: false }).where.not(comments: { user_id: user.id }).order("receipts.created_at DESC")
  end

  def first_unread_message_for user
    receipts.unread.where(user_id: user.id).first
  end

  def initiater
    messages.first.user
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
    User.joins("INNER JOIN receipts ON receipts.user_id = users.id").joins("INNER JOIN comments ON receipts.receivable_id = comments.id AND receipts.receivable_type = 'Comment'").joins("INNER JOIN conversations ON comments.commentable_id = conversations.id AND comments.commentable_type = 'Conversation'").where(conversations: { id: id }).distinct('users.id')
  end

  def sender
    @sender ||= (sender_id.present? ? User.find_by_id(sender_id) : nil)
  end

  private
    def create_message
      message = messages.new raw_body: body
      message.user_id = sender_id
      message.save
      message.receipts.create user_id: recipient_id
      message.receipts.create user_id: sender_id, read: true
    end

    def create_reply
      message = messages.new raw_body: body
      message.user_id = sender_id
      message.save
      participants.where.not(users: { id: sender_id }).each do |recipient|
        message.receipts.create user_id: recipient.id
      end
      message.receipts.create user_id: sender_id, read: true
    end

    def sender_is_not_spamming
      return if sender.is? :trusted

      if Conversation.joins("INNER JOIN (SELECT distinct on (commentable_type, commentable_id) * FROM comments WHERE comments.commentable_type = 'Conversation' ORDER BY commentable_type, commentable_id, created_at) AS c ON c.commentable_id = conversations.id").where("c.user_id = ?", sender_id).where("conversations.created_at > ?", 24.hours.ago).count >= 5

        errors.add :sender_id, "You're sending too many messages and your account has been put on hold. Please email us at hi@hackster.io if you believe this is a mistake."
        self.is_spam = true
      end
    end

    def subject_is_unique
      return if sender.is? :trusted

      if self.class.where(subject: subject).where("conversations.created_at > ?", 24.hours.ago).any?
        errors.add :subject, 'has already been used recently. No spam please!'
        self.is_spam = true
      end
    end
  end