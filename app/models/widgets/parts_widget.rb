class PartsWidget < Widget

  def self.model_name
    Widget.model_name
  end

  has_many :parts, as: :partable

  define_attributes [:total_cost]

  attr_accessible :parts_attributes
  accepts_nested_attributes_for :parts, allow_destroy: true
  before_save :compute_total_cost

  def help_text
    "Add parts."
  end

  private
    def compute_total_cost
      Octopart.match parts.select{ |p| p.changed? }  # only changed parts
      total = 0
      parts.each{ |p| total += p.total_cost || 0 }
      self.total_cost = total.round(4)
    end
end
