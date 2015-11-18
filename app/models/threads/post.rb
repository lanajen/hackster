class Post < ThreadPost
  include Privatable

  belongs_to :threadable, polymorphic: true
  has_many :widgets, as: :widgetable

  attr_accessible :private, :draft, :widget_attributes

  accepts_nested_attributes_for :widgets

  before_create :generate_sub_id

  def draft?
    draft
  end

  protected
    def generate_sub_id
      self.sub_id = ThreadPost.where(threadable_type: threadable_type, threadable_id: threadable_id, type: type).size + 1
    end
end
