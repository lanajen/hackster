class SkillRequest < ThreadPost
  before_create :set_threadable
  validates :body, presence: true

  private
    def set_threadable
      self.threadable_id = 1
      self.threadable_type = 'SkillRequest'
    end
end