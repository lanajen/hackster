class Stage < ActiveRecord::Base
  belongs_to :project
  has_many :widgets, dependent: :destroy

  attr_accessible :completion_rate, :name, :project_id

  def update_completion_rate!
    self.completion_rate = if widgets.count > 0
      total = 0
      widgets.each{ |w| total += w.completion_rate * w.completion_share / 100 }
      total
    else
      0
    end
    save
  end
end
