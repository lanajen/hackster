class Post < ThreadPost
  include Privatable

  belongs_to :threadable, polymorphic: true

  attr_accessible :private

  before_create :generate_sub_id

  private
    def generate_sub_id
      self.sub_id = ThreadPost.where(threadable_type: threadable_type, threadable_id: threadable_id, type: type).size + 1
    end
end
