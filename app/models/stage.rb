class Stage < ActiveRecord::Base
  include Workflow

  workflow do
    state :locked do
      event :unlock, transitions_to: :open
    end
    state :open do
      event :complete, transitions_to: :completed
    end
    state :completed do
      event :reopen, transitions_to: :open
    end
  end

  belongs_to :project
  has_many :widgets, dependent: :destroy

  attr_accessible :completion_rate, :name, :project_id

  def public?
    private == false
  end
  attr_accessible :private, :privacy_rules_attributes
  has_many :privacy_rules, as: :privatable
  accepts_nested_attributes_for :privacy_rules, allow_destroy: true

  def visible_to? user
    public? or user.has_access_group_permissions? self or user.is_team_member? project
  end

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
