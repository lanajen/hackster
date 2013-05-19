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
      total = 0
      parts.each{ |p| total += p.total_cost }
      self.total_cost = total.round(2)
    end
end
