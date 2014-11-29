class BuildLog < ThreadPost
  DEFAULT_TITLE = 'Untitled'

  has_many :widgets, as: :widgetable

  attr_accessible :widgets_attributes, :draft
  accepts_nested_attributes_for :widgets

  skip_callback :create, :before, :generate_sub_id
  before_update :generate_sub_id, if: proc{|b| !b.draft? and b.sub_id == 0 }
  before_create :set_draft

  self.per_page = 10

  def self.published
    where(draft: false)
  end

  def draft?
    draft
  end

  def title
    super.presence || DEFAULT_TITLE
  end

  private
    def generate_sub_id
      self.sub_id = self.class.where(threadable_type: threadable_type, threadable_id: threadable_id).published.size + 1
    end

    def set_draft
      self.draft = true
    end
end
