class ThreadPost < ActiveRecord::Base
  include Privatable
  self.table_name = :threads

  belongs_to :threadable, polymorphic: true
  belongs_to :user
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  # below is a hack because commenters try to add order by comments created_at and pgsql doesn't like it
  has_many :comments_copy, as: :commentable, dependent: :destroy, class_name: 'Comment'
  has_many :commenters, -> { uniq true }, through: :comments_copy, source: :user

  attr_accessible :body, :private, :title

  validates :title, presence: true
  before_create :generate_sub_id

  private
    def generate_sub_id
      self.sub_id = ThreadPost.where(threadable_type: threadable_type, threadable_id: threadable_id, type: type).size + 1
    end
end
